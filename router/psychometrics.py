import os
import logging
import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/psychometrics", tags=["Psychometric Engine"])
DATABASE_URL = os.getenv("DATABASE_URL")

# --- Pydantic Schemas ---
class QuestionOut(BaseModel):
    id: int
    text: str
    # We hide 'trait' and 'reverse' so the frontend can't cheat!

class QuestionListResponse(BaseModel):
    module: str
    total_questions: int
    questions: List[QuestionOut]

class AnswerInput(BaseModel):
    question_id: int
    score: int  # 1 to 5

class TestSubmission(BaseModel):
    user_id: str
    answers: List[AnswerInput]

# --- 1. Dynamic Question Fetcher ---
@router.get("/{module}/questions", response_model=QuestionListResponse)
async def get_psychometric_questions(module: str, limit: int = 25):
    """
    Dynamically fetches random questions for EQ, Personality, Orientation, or Interest.
    """
    valid_modules = ["personality", "eq", "orientation", "interest"]
    if module.lower() not in valid_modules:
        raise HTTPException(status_code=400, detail=f"Invalid module. Choose from {valid_modules}")

    query = """
    SELECT id, text 
    FROM psychometric_questions 
    WHERE module = %s 
    ORDER BY RANDOM() 
    LIMIT %s;
    """
    
    try:
        with psycopg2.connect(DATABASE_URL) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(query, (module.lower(), limit))
                rows = cur.fetchall()

        if not rows:
            raise HTTPException(status_code=404, detail="No questions found for this module.")

        return QuestionListResponse(
            module=module,
            total_questions=len(rows),
            questions=[QuestionOut(**row) for row in rows]
        )

    except Exception as e:
        logger.error(f"Error fetching {module} questions: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed.")

# --- 2. The Universal Scorer ---
@router.post("/{module}/score")
async def score_psychometric_test(module: str, submission: TestSubmission):
    """
    Scores the test, calculates dominant traits, and saves directly to the `users` table.
    """
    # 1. Fetch the exact grading key for the submitted questions
    question_ids = tuple([ans.question_id for ans in submission.answers])
    if not question_ids:
        raise HTTPException(status_code=400, detail="No answers provided.")

    query = """
    SELECT id, trait, is_reverse_scored 
    FROM psychometric_questions 
    WHERE id IN %s;
    """
    
    raw_scores = {}
    
    try:
        with psycopg2.connect(DATABASE_URL) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(query, (question_ids,))
                grading_keys = cur.fetchall()

            # Create a dictionary for fast lookup: {1: {'trait': 'Empathy', 'reverse': False}}
            key_map = {row['id']: row for row in grading_keys}

            # 2. Calculate Scores
            for ans in submission.answers:
                if ans.question_id not in key_map:
                    continue # Skip invalid questions
                
                grading_info = key_map[ans.question_id]
                trait = grading_info['trait']
                is_reverse = grading_info['is_reverse_scored']
                
                # Initialize trait in dictionary if it doesn't exist
                if trait not in raw_scores:
                    raw_scores[trait] = 0

                # Apply 1-5 Likert scale reverse scoring (6 - score)
                final_score = (6 - ans.score) if is_reverse else ans.score
                raw_scores[trait] += final_score

            # 3. Find Dominant Traits (Top 2 highest scoring traits)
            sorted_traits = sorted(raw_scores.items(), key=lambda item: item[1], reverse=True)
            dominant_traits = [trait for trait, score in sorted_traits[:2]]

            # 4. Save to the Users Table
            # Map the module to the actual database column
            column_map = {
                "personality": "personality_data",
                "eq": "eq_data",
                "orientation": "orientation_data",
                "interest": "career_interest_data"
            }
            
            target_col = column_map.get(module.lower())
            
            final_payload = {
                "raw_scores": raw_scores,
                "dominant_traits": dominant_traits,
                "status": "completed"
            }

            import json
            update_query = f"UPDATE users SET {target_col} = %s, updated_at = NOW() WHERE id = %s;"
            
            with conn.cursor() as cur:
                cur.execute(update_query, (json.dumps(final_payload), submission.user_id))
            
            conn.commit()

        return {
            "status": "success",
            "message": f"{module.capitalize()} test graded and saved successfully.",
            "data": final_payload
        }

    except Exception as e:
        logger.error(f"Error scoring {module}: {e}")
        raise HTTPException(status_code=500, detail=str(e))