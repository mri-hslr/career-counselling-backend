import logging
from datetime import datetime
from uuid import UUID
from fastapi import (
    APIRouter, Depends, HTTPException, Query,
    WebSocket, WebSocketDisconnect,
)
from jose import jwt, JWTError
from pydantic import BaseModel
from sqlalchemy.orm import Session

from core.database import get_db
from core.security import SECRET_KEY, ALGORITHM
from api.deps import get_current_user
from models.users import User, UserRole
from models.mentorship import Mentor, MentorAvailability, SessionLog, ChatMessage, MentorFeedback

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1", tags=["Mentorship"])


# ── WebSocket connection manager ─────────────────────────────────────────────

class ConnectionManager:
    def __init__(self):
        self._rooms: dict[str, list[WebSocket]] = {}

    async def connect(self, room: str, ws: WebSocket):
        await ws.accept()
        self._rooms.setdefault(room, []).append(ws)

    def disconnect(self, room: str, ws: WebSocket):
        room_list = self._rooms.get(room, [])
        if ws in room_list:
            room_list.remove(ws)

    async def broadcast(self, room: str, payload: dict):
        for ws in self._rooms.get(room, []):
            await ws.send_json(payload)


manager = ConnectionManager()


# ── Mentor profile creation ──────────────────────────────────────────────────

class MentorProfileIn(BaseModel):
    expertise: str


@router.post("/profiles/mentors/", status_code=201)
def create_mentor_profile(
    body: MentorProfileIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.MENTOR:
        raise HTTPException(status_code=403, detail="Only users with role=mentor can create a mentor profile.")

    if db.query(Mentor).filter(Mentor.user_id == current_user.id).first():
        raise HTTPException(status_code=409, detail="Mentor profile already exists.")

    mentor = Mentor(user_id=current_user.id, expertise=body.expertise)
    db.add(mentor)
    db.commit()
    db.refresh(mentor)
    return {"mentor_id": str(mentor.id), "message": "Mentor profile created. Awaiting admin verification."}


# ── List all verified mentors (public) ──────────────────────────────────────

@router.get("/profiles/mentors/")
def list_verified_mentors(db: Session = Depends(get_db)):
    mentors = db.query(Mentor).filter(Mentor.is_verified == True).all()
    return [
        {
            "mentor_id": str(m.id),
            "expertise": m.expertise,
            "rating": m.rating,
        }
        for m in mentors
    ]


# ── Mentor sets availability ─────────────────────────────────────────────────

class AvailabilityIn(BaseModel):
    day_of_week: int   # 1 = Monday … 7 = Sunday
    start_time: str    # "HH:MM"
    end_time: str      # "HH:MM"


@router.post("/mentorship/availability/", status_code=201)
def set_availability(
    body: AvailabilityIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    mentor = db.query(Mentor).filter(Mentor.user_id == current_user.id).first()
    if not mentor:
        raise HTTPException(status_code=404, detail="Mentor profile not found.")
    if not mentor.is_verified:
        raise HTTPException(status_code=403, detail="Only verified mentors can set availability.")
    if not (1 <= body.day_of_week <= 7):
        raise HTTPException(status_code=400, detail="day_of_week must be between 1 (Mon) and 7 (Sun).")

    try:
        start = datetime.strptime(body.start_time, "%H:%M").time()
        end = datetime.strptime(body.end_time, "%H:%M").time()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid time format. Use HH:MM (e.g. '14:30').")

    if start >= end:
        raise HTTPException(status_code=400, detail="start_time must be earlier than end_time.")

    slot = MentorAvailability(
        mentor_id=mentor.id,
        day_of_week=body.day_of_week,
        start_time=start,
        end_time=end,
    )
    db.add(slot)
    db.commit()
    db.refresh(slot)
    return {"availability_id": str(slot.id), "message": "Availability slot created."}


# ── Get open availability slots for a mentor (public) ───────────────────────

DAY_NAMES = {1: "Monday", 2: "Tuesday", 3: "Wednesday", 4: "Thursday",
             5: "Friday", 6: "Saturday", 7: "Sunday"}


@router.get("/mentorship/availability/{mentor_id}")
def get_mentor_availability(mentor_id: UUID, db: Session = Depends(get_db)):
    slots = (
        db.query(MentorAvailability)
        .filter(
            MentorAvailability.mentor_id == mentor_id,
            MentorAvailability.is_booked == False,
        )
        .all()
    )
    return [
        {
            "availability_id": str(s.id),
            "day": DAY_NAMES.get(s.day_of_week, str(s.day_of_week)),
            "start_time": s.start_time.strftime("%H:%M"),
            "end_time": s.end_time.strftime("%H:%M"),
        }
        for s in slots
    ]


# ── Student books a session ──────────────────────────────────────────────────

class SessionBookIn(BaseModel):
    mentor_id: UUID
    availability_id: UUID
    scheduled_at: datetime
    duration_minutes: int = 60


@router.post("/mentorship/sessions/", status_code=201)
def book_session(
    body: SessionBookIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Only students can book sessions.")

    # Lock the slot — check it's still free and belongs to the right mentor
    slot = (
        db.query(MentorAvailability)
        .filter(
            MentorAvailability.id == body.availability_id,
            MentorAvailability.mentor_id == body.mentor_id,
            MentorAvailability.is_booked == False,
        )
        .with_for_update()   # row-level lock to prevent double-booking
        .first()
    )
    if not slot:
        raise HTTPException(status_code=409, detail="This slot is unavailable or already booked.")

    session = SessionLog(
        student_id=current_user.id,
        mentor_id=body.mentor_id,
        scheduled_at=body.scheduled_at,
        duration_minutes=body.duration_minutes,
        status="scheduled",
    )
    db.add(session)
    slot.is_booked = True
    db.commit()
    db.refresh(session)
    return {"session_id": str(session.id), "message": "Session booked successfully."}


# ── Mentor submits action-item feedback ─────────────────────────────────────

class MentorFeedbackIn(BaseModel):
    session_id: UUID
    notes: str = ""
    action_items: str = ""


@router.post("/mentorship/feedback/mentor/", status_code=201)
def submit_mentor_feedback(
    body: MentorFeedbackIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    mentor = db.query(Mentor).filter(Mentor.user_id == current_user.id).first()
    if not mentor:
        raise HTTPException(status_code=404, detail="Mentor profile not found.")

    session = (
        db.query(SessionLog)
        .filter(SessionLog.id == body.session_id, SessionLog.mentor_id == mentor.id)
        .first()
    )
    if not session:
        raise HTTPException(status_code=404, detail="Session not found or not assigned to you.")

    db.add(MentorFeedback(
        session_id=body.session_id,
        mentor_id=mentor.id,
        student_id=session.student_id,
        notes=body.notes,
        action_items=body.action_items,
    ))
    db.commit()
    return {"message": "Feedback submitted successfully."}


# ── WebSocket: real-time session chat ────────────────────────────────────────

@router.websocket("/mentorship/sessions/{session_id}/chat/")
async def websocket_chat(
    websocket: WebSocket,
    session_id: UUID,
    token: str = Query(..., description="JWT bearer token passed as query param"),
    db: Session = Depends(get_db),
):
    # Authenticate via JWT from query param (browsers can't set WS headers)
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if not email:
            await websocket.close(code=1008)
            return
    except JWTError:
        await websocket.close(code=1008)
        return

    user = db.query(User).filter(User.email == email).first()
    if not user:
        await websocket.close(code=1008)
        return

    # Verify the user is a participant of this session
    session = db.query(SessionLog).filter(SessionLog.id == session_id).first()
    if not session:
        await websocket.close(code=1008)
        return

    mentor = db.query(Mentor).filter(Mentor.id == session.mentor_id).first()
    is_participant = session.student_id == user.id or (mentor and mentor.user_id == user.id)
    if not is_participant:
        await websocket.close(code=1008)
        return

    room = str(session_id)
    await manager.connect(room, websocket)
    logger.info(f"User {user.id} joined chat room {room}")

    try:
        while True:
            data = await websocket.receive_json()
            text = (data.get("message") or "").strip()
            if not text:
                continue

            msg = ChatMessage(session_id=session_id, sender_id=user.id, message=text)
            db.add(msg)
            db.commit()
            db.refresh(msg)

            await manager.broadcast(room, {
                "message_id": str(msg.id),
                "sender_id": str(user.id),
                "message": text,
                "sent_at": msg.sent_at.isoformat(),
            })
    except WebSocketDisconnect:
        manager.disconnect(room, websocket)
        logger.info(f"User {user.id} left chat room {room}")
