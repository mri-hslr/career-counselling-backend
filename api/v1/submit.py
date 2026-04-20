import os
import logging
import json
import psycopg2
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Dict, Any, Optional

# 1. Router Setup
router = APIRouter(prefix="/api/v1/assessments", tags=["Submission"])

# 2. Configuration
DATABASE_URL = os.getenv("DATABASE_URL")
logger = logging.getLogger(__name__)

# 3. The Mapping Logic (Verified against your SQL results)
# This maps the "Frontend Module Name" to the "Actual Database Column"
COLUMN_MAPPING = {
    "profile": "profile_data",
    "academic": "academic_data",
    "aptitude": "apti_data",
    "personality": "personality_data",
    "lifestyle": "lifestyle_data",
    "financial": "financial_data",
    "passion": "passion_strength_data",
    "aspiration": "aspiration_data",
    "interest":"career_interest_data",
    "eq": "eq_data",                   # 👉 NEW
    "orientation": "orientation_data"
    
}

class UniversalSubmission(BaseModel):
    user_id: str
    module_key: str  # e.g., "lifestyle", "academic"
    payload: Dict[str, Any]  # The "Template Swapped" JSON blob

@router.post("/submit-generic")
async def submit_generic_assessment(submission: UniversalSubmission):
    """
    Universal sync endpoint:
    Takes a JSON blob from the frontend, identifies the target column 
    based on the module_key, and persists it to the users table.
    """
    
    # Normalize the key to lowercase to prevent mapping misses
    key = submission.module_key.lower()
    
    # 1. Validation: Ensure the module actually exists in our schema
    target_column = COLUMN_MAPPING.get(key)
    
    if not target_column:
        logger.warning(f"Submission attempt for unsupported module: {key}")
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid module key: '{key}'. Supported: {list(COLUMN_MAPPING.keys())}"
        )

    # 2. Atomic Database Update
    # Using parameterized queries to prevent SQL injection
    query = f"""
    UPDATE users 
    SET {target_column} = %s, 
        updated_at = NOW() 
    WHERE id = %s;
    """

    try:
        with psycopg2.connect(DATABASE_URL) as conn:
            with conn.cursor() as cur:
                # Convert the Python dictionary payload to a JSON string for Postgres
                cur.execute(query, (json.dumps(submission.payload), submission.user_id))
            
            # Commit the transaction
            conn.commit()
            
        logger.info(f"Successfully synced {key} for User: {submission.user_id}")
        
        return {
            "status": "success",
            "message": f"Module '{key}' has been successfully persisted to '{target_column}'",
            "module_synced": key
        }

    except Exception as e:
        logger.error(f"Database Error during {key} submission: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Internal Server Error: Data persistence failed."
        )


# ── TEST PROGRESS (Save & Resume) ─────────────────────────────────────────────

class SaveProgressBody(BaseModel):
    user_id: str
    test_key: str  # e.g. "aptitude" — stored as a marker in the relevant JSONB column
    session_questions: list  # serialized question objects
    answers: Dict[str, Any]  # { question_index_or_id: selected_letter }
    current_index: int

class GetProgressBody(BaseModel):
    user_id: str
    test_key: str

@router.patch("/save-progress")
async def save_test_progress(body: SaveProgressBody):
    """
    Saves mid-test progress into the user's JSONB column so they can resume later.
    Stores a '_progress' key inside the relevant column (e.g. apti_data._progress).
    """
    key_map = {
        "aptitude": "apti_data",
    }
    target_col = key_map.get(body.test_key.lower())
    if not target_col:
        raise HTTPException(status_code=400, detail=f"Unsupported test_key: {body.test_key}")

    progress_payload = {
        "_status": "in_progress",
        "_session_questions": body.session_questions,
        "_answers": body.answers,
        "_current_index": body.current_index,
    }

    # Merge into the existing JSONB column using ||
    query = f"""
    UPDATE users
    SET {target_col} = COALESCE({target_col}, '{{}}'::jsonb) || %s::jsonb,
        updated_at = NOW()
    WHERE id = %s;
    """
    try:
        with psycopg2.connect(DATABASE_URL) as conn:
            with conn.cursor() as cur:
                cur.execute(query, (json.dumps(progress_payload), body.user_id))
            conn.commit()
        return {"status": "saved", "current_index": body.current_index}
    except Exception as e:
        logger.error(f"save-progress error: {e}")
        raise HTTPException(status_code=500, detail="Failed to save progress.")


@router.get("/progress/{test_key}/{user_id}")
async def get_test_progress(test_key: str, user_id: str):
    """
    Returns in-progress test state if it exists, so the frontend can resume.
    Returns null if no in-progress session found.
    """
    key_map = {"aptitude": "apti_data"}
    target_col = key_map.get(test_key.lower())
    if not target_col:
        raise HTTPException(status_code=400, detail=f"Unsupported test_key: {test_key}")

    query = f"SELECT {target_col} FROM users WHERE id = %s;"
    try:
        with psycopg2.connect(DATABASE_URL) as conn:
            with conn.cursor() as cur:
                cur.execute(query, (user_id,))
                row = cur.fetchone()

        if not row or not row[0]:
            return {"in_progress": False}

        col_data = row[0] if isinstance(row[0], dict) else json.loads(row[0])
        if col_data.get("_status") == "in_progress":
            return {
                "in_progress": True,
                "session_questions": col_data.get("_session_questions", []),
                "answers": col_data.get("_answers", {}),
                "current_index": col_data.get("_current_index", 0),
            }
        return {"in_progress": False}
    except Exception as e:
        logger.error(f"get-progress error: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch progress.")