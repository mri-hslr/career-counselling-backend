"""
24-hour Ephemeral Chat — REST endpoints for connection list and message history.
The actual real-time messaging goes through the existing WebSocket endpoint in mentor.py.
"""
import asyncio
import logging
from datetime import datetime, timedelta, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import and_

from core.database import get_db, SessionLocal
from api.deps import get_current_user
from models.users import User, UserRole
from models.mentorship import ChatMessage, MentorshipRequest, Mentor

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/chat", tags=["Chat"])

# ── Helpers ───────────────────────────────────────────────────────────────────

def _cutoff() -> datetime:
    """Returns the UTC timestamp exactly 24 hours ago (tz-aware)."""
    return datetime.now(timezone.utc) - timedelta(hours=24)


def _resolve_pair(current_user: User, other_user_id: UUID, db: Session):
    """
    Given two user IDs, figure out which is the student and which is the mentor,
    then return (student_user_id, mentor_profile_id) or raise 403/404.
    """
    current_mentor = db.query(Mentor).filter(Mentor.user_id == current_user.id).first()
    other_mentor   = db.query(Mentor).filter(Mentor.user_id == other_user_id).first()

    if current_mentor and not other_mentor:
        mentor_profile_id = current_mentor.id
        student_user_id   = other_user_id
    elif other_mentor and not current_mentor:
        mentor_profile_id = other_mentor.id
        student_user_id   = current_user.id
    else:
        raise HTTPException(
            status_code=400,
            detail="Could not resolve mentor/student relationship between these two users."
        )
    return student_user_id, mentor_profile_id


# ── GET /chat/connections ─────────────────────────────────────────────────────

@router.get("/connections")
def get_chat_connections(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Returns the list of users this person can chat with — i.e. those whose
    mentorship_request.status is 'accepted' OR 'approved'.
    Works for both students and mentors.
    """
    mentor_profile = db.query(Mentor).filter(Mentor.user_id == current_user.id).first()

    if mentor_profile:
        # Caller is a MENTOR — return all accepted/approved students (deduplicated)
        rows = (
            db.query(MentorshipRequest, User)
            .join(User, MentorshipRequest.student_id == User.id)
            .filter(
                MentorshipRequest.mentor_id == mentor_profile.id,
                MentorshipRequest.status.in_(["accepted", "approved"]),
            )
            .order_by(MentorshipRequest.updated_at.desc())
            .all()
        )
        seen: set = set()
        result = []
        for req, student in rows:
            uid = str(student.id)
            if uid not in seen:
                seen.add(uid)
                result.append({
                    "user_id":      uid,
                    "full_name":    student.full_name or student.email,
                    "role":         "student",
                    "request_type": req.request_type,
                })
        return result
    else:
        # Caller is a STUDENT — return all accepted mentors (deduplicated)
        rows = (
            db.query(MentorshipRequest, Mentor, User)
            .join(Mentor, MentorshipRequest.mentor_id == Mentor.id)
            .join(User,   Mentor.user_id == User.id)
            .filter(
                MentorshipRequest.student_id == current_user.id,
                MentorshipRequest.status.in_(["accepted", "approved"]),
            )
            .order_by(MentorshipRequest.updated_at.desc())
            .all()
        )
        seen: set = set()
        result = []
        for req, _mentor, mentor_user in rows:
            uid = str(mentor_user.id)
            if uid not in seen:
                seen.add(uid)
                result.append({
                    "user_id":      uid,
                    "full_name":    mentor_user.full_name or mentor_user.email,
                    "role":         "mentor",
                    "request_type": req.request_type,
                })
        return result


# ── GET /chat/messages/{other_user_id} ───────────────────────────────────────

@router.get("/messages/{other_user_id}")
def get_chat_messages(
    other_user_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Returns all chat messages between the current user and other_user_id
    from the last 24 hours only (ephemeral window).
    """
    student_user_id, mentor_profile_id = _resolve_pair(current_user, other_user_id, db)

    messages = (
        db.query(ChatMessage)
        .filter(
            ChatMessage.student_id == student_user_id,
            ChatMessage.mentor_id  == mentor_profile_id,
            ChatMessage.sent_at    >= _cutoff(),
        )
        .order_by(ChatMessage.sent_at.asc())
        .all()
    )

    return [
        {
            "id":        str(m.id),
            "sender_id": str(m.sender_id),
            "message":   m.message,
            "sent_at":   m.sent_at.isoformat(),
            "is_me":     m.sender_id == current_user.id,
        }
        for m in messages
    ]


# ── DELETE /chat/connections/{other_user_id} ──────────────────────────────────

@router.delete("/connections/{other_user_id}", status_code=200)
def delete_connection(
    other_user_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Severs the accepted connection between the current user and other_user_id.
    Deletes:
      - ALL chat_messages between the pair (both directions)
      - The mentorship_request row(s) linking them (accepted/approved)
    """
    student_user_id, mentor_profile_id = _resolve_pair(current_user, other_user_id, db)

    # Delete all chat messages between the pair
    db.query(ChatMessage).filter(
        ChatMessage.student_id == student_user_id,
        ChatMessage.mentor_id  == mentor_profile_id,
    ).delete(synchronize_session=False)

    # Delete the connection request(s) — status accepted or approved
    deleted = db.query(MentorshipRequest).filter(
        MentorshipRequest.student_id == student_user_id,
        MentorshipRequest.mentor_id  == mentor_profile_id,
        MentorshipRequest.status.in_(["accepted", "approved"]),
    ).delete(synchronize_session=False)

    if deleted == 0:
        db.rollback()
        raise HTTPException(status_code=404, detail="No active connection found to delete.")

    db.commit()
    return {"detail": "Connection and chat history deleted."}


# ── Background cleanup task ───────────────────────────────────────────────────

async def purge_old_messages_loop():
    """
    Runs forever in the background. Every hour it deletes chat_messages
    older than 24 hours, preventing DB bloat.
    """
    while True:
        try:
            await asyncio.sleep(3600)  # wait 1 hour between runs
            db: Session = SessionLocal()
            try:
                deleted = (
                    db.query(ChatMessage)
                    .filter(ChatMessage.sent_at < _cutoff())
                    .delete(synchronize_session=False)
                )
                db.commit()
                if deleted:
                    logger.info(f"[chat-cleanup] Purged {deleted} messages older than 24h.")
            finally:
                db.close()
        except asyncio.CancelledError:
            break
        except Exception as exc:
            logger.error(f"[chat-cleanup] Error during purge: {exc}")
