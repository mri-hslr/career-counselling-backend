import random
import string
import logging
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from api.deps import get_current_user
from models.users import User, UserRole
from models.mentorship import ParentStudentLink, ParentFeedback, MentorFeedback
from models.roadmaps import Roadmap
from api.v1.roadmap import RoadmapResponse

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1", tags=["Parent-Student Linking"])


def _unique_invite_code(db: Session) -> str:
    """Generate a 6-char alphanumeric code guaranteed to be unique in the DB."""
    while True:
        code = "".join(random.choices(string.ascii_uppercase + string.digits, k=6))
        if not db.query(User).filter(User.invite_code == code).first():
            return code


# ── Task 3.2: Student retrieves their invite code ─────────────────────

@router.get("/students/invite-code")
def get_student_invite_code(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Only students can access their invite code."
        )

    if not current_user.invite_code:
        try:
            current_user.invite_code = _unique_invite_code(db)
            db.commit()
            db.refresh(current_user)
        except Exception as e:
            db.rollback()
            logger.error(f"Error generating invite code: {str(e)}")
            raise HTTPException(status_code=500, detail="Failed to generate invite code.")

    return {"invite_code": current_user.invite_code}


# ── Task 3.3: Parent links to a student via invite code ─────────────────────

class LinkStudentRequest(BaseModel):
    invite_code: str


@router.post("/parents/link-student", status_code=201)
def link_student_to_parent(
    body: LinkStudentRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.PARENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Only parents can link to a student profile."
        )

    # 1. Find student by invite code
    student = db.query(User).filter(
        User.invite_code == body.invite_code.upper().strip()
    ).first()
    
    if not student or student.role != UserRole.STUDENT:
        raise HTTPException(status_code=404, detail="Invalid invite code. No student found.")

    # 2. Check for existing link
    already_linked = db.query(ParentStudentLink).filter(
        ParentStudentLink.parent_id == current_user.id,
        ParentStudentLink.student_id == student.id,
    ).first()
    
    if already_linked:
        return {"message": "Already linked to this student.", "student_id": str(student.id)}

    # 3. Create link
    try:
        new_link = ParentStudentLink(parent_id=current_user.id, student_id=student.id)
        db.add(new_link)
        db.commit()
        return {"message": "Successfully linked to student.", "student_id": str(student.id)}
    except Exception as e:
        db.rollback()
        logger.error(f"Error linking parent to student: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to create link.")


# ── Parent: read student's saved roadmap from DB ─────────────────────────────

@router.get("/parent/roadmaps/{student_id}", response_model=RoadmapResponse)
def get_linked_student_roadmap(
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

    roadmap = (
        db.query(Roadmap)
        .options(joinedload(Roadmap.phases).joinedload("tasks"))
        .filter(Roadmap.student_id == student_id)
        .order_by(Roadmap.created_at.desc())
        .first()
    )
    if not roadmap:
        raise HTTPException(status_code=404, detail="No roadmap found for this student yet.")

    return roadmap


# ── Parent: submit behavioral/study feedback ─────────────────────────────────

class ParentFeedbackIn(BaseModel):
    student_id: UUID
    study_habits: str = ""
    behavior_insights: str = ""


@router.post("/parent/feedback", status_code=201)
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

@router.get("/parents/linked-student")
def get_linked_student_status(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != UserRole.PARENT:
        raise HTTPException(status_code=403, detail="Only parents can check linked students.")
        
    link = db.query(ParentStudentLink).filter(ParentStudentLink.parent_id == current_user.id).first()
    
    if not link:
        return {"is_linked": False, "student": None}
        
    student = db.query(User).filter(User.id == link.student_id).first()
    
    if not student:
        return {"is_linked": False, "student": None}
        
    return {
        "is_linked": True,
        "student": {
            "id": str(student.id),
            "full_name": student.full_name or "Student",
            "email": student.email
        }
    }
