import random
import string
import logging
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from core.database import get_db
from api.deps import get_current_user
from models.users import User, UserRole
from models.mentorship import ParentStudentLink, ParentFeedback, MentorFeedback
from api.v1.roadmap import (
    generate_roadmap, CareerRoadmapResponse,
    _academic_summary, _aptitude_summary, _personality_summary,
    _study_hours, _financial_context,
)

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1", tags=["Parent"])


def _unique_invite_code(db: Session) -> str:
    """Generate a 6-char alphanumeric code guaranteed to be unique in the DB."""
    while True:
        code = "".join(random.choices(string.ascii_uppercase + string.digits, k=6))
        if not db.query(User).filter(User.invite_code == code).first():
            return code


# ── Student: get (or lazily generate) their invite code ─────────────────────

@router.get("/profiles/students/invite-code")
def get_invite_code(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Only students can generate invite codes.")

    if not current_user.invite_code:
        current_user.invite_code = _unique_invite_code(db)
        db.commit()
        db.refresh(current_user)

    return {"invite_code": current_user.invite_code}


# ── Parent: link to a student via invite code ────────────────────────────────

class LinkRequest(BaseModel):
    invite_code: str


@router.post("/profiles/students/link/", status_code=201)
def link_parent_to_student(
    body: LinkRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.PARENT:
        raise HTTPException(status_code=403, detail="Only parents can link to a student.")

    student = db.query(User).filter(
        User.invite_code == body.invite_code.upper().strip()
    ).first()
    if not student or student.role != UserRole.STUDENT:
        raise HTTPException(status_code=404, detail="Invalid invite code.")

    already_linked = db.query(ParentStudentLink).filter(
        ParentStudentLink.parent_id == current_user.id,
        ParentStudentLink.student_id == student.id,
    ).first()
    if already_linked:
        raise HTTPException(status_code=409, detail="Already linked to this student.")

    db.add(ParentStudentLink(parent_id=current_user.id, student_id=student.id))
    db.commit()
    return {"message": "Successfully linked to student.", "student_id": str(student.id)}


# ── Parent: read student's roadmap (auth-gated) ──────────────────────────────

@router.get("/roadmaps/{student_id}", response_model=CareerRoadmapResponse)
async def get_student_roadmap(
    student_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.PARENT:
        raise HTTPException(status_code=403, detail="Only parents can access this endpoint.")

    link = db.query(ParentStudentLink).filter(
        ParentStudentLink.parent_id == current_user.id,
        ParentStudentLink.student_id == student_id,
    ).first()
    if not link:
        raise HTTPException(status_code=403, detail="You are not linked to this student.")

    student = db.query(User).filter(User.id == student_id).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found.")

    # Career goal from student's aspiration data
    career_goal = "Software Engineer"
    vision = ""
    if isinstance(student.aspiration_data, dict):
        career_goal = student.aspiration_data.get("dream_career") or career_goal
        vision = student.aspiration_data.get("ten_year_vision") or ""

    # Parent observations
    parent_rows = (
        db.query(ParentFeedback)
        .filter(ParentFeedback.student_id == student_id)
        .order_by(ParentFeedback.logged_at.desc())
        .limit(3)
        .all()
    )
    parent_observations = (
        "\n".join(
            f"• Study: {f.study_habits or 'N/A'} | Behavior: {f.behavior_insights or 'N/A'}"
            for f in parent_rows
        ) or "None"
    )

    # Mentor action items
    mentor_rows = (
        db.query(MentorFeedback)
        .filter(MentorFeedback.student_id == student_id)
        .order_by(MentorFeedback.submitted_at.desc())
        .limit(3)
        .all()
    )
    mentor_action_items = (
        "\n".join(f"• {r.action_items}" for r in mentor_rows if r.action_items)
        or "None"
    )

    return await generate_roadmap(
        career_goal=career_goal,
        vision=vision,
        academic_summary=_academic_summary(student.academic_data),
        aptitude_summary=_aptitude_summary(student.apti_data),
        personality_summary=_personality_summary(student.personality_data),
        study_hours=_study_hours(student.lifestyle_data),
        financial_context=_financial_context(student.financial_data),
        mentor_action_items=mentor_action_items,
        parent_observations=parent_observations,
    )


# ── Parent: submit behavioral/study feedback ─────────────────────────────────

class ParentFeedbackIn(BaseModel):
    student_id: UUID
    study_habits: str = ""
    behavior_insights: str = ""


@router.post("/mentorship/feedback/parent/", status_code=201)
def submit_parent_feedback(
    body: ParentFeedbackIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.PARENT:
        raise HTTPException(status_code=403, detail="Only parents can submit feedback.")

    link = db.query(ParentStudentLink).filter(
        ParentStudentLink.parent_id == current_user.id,
        ParentStudentLink.student_id == body.student_id,
    ).first()
    if not link:
        raise HTTPException(status_code=403, detail="You are not linked to this student.")

    db.add(ParentFeedback(
        parent_id=current_user.id,
        student_id=body.student_id,
        study_habits=body.study_habits,
        behavior_insights=body.behavior_insights,
    ))
    db.commit()
    return {"message": "Feedback submitted successfully."}
