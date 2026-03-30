import logging
from datetime import datetime
from uuid import UUID
from typing import List, Optional

from fastapi import (
    APIRouter, Depends, HTTPException, Query,
    WebSocket, WebSocketDisconnect,
)
from jose import jwt, JWTError
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import func
from sentence_transformers import SentenceTransformer

from core.database import get_db
from core.security import SECRET_KEY, ALGORITHM
from api.deps import get_current_user
from models.users import User, UserRole
from models.mentorship import (
    Mentor, MentorAvailability, SessionLog, 
    ChatMessage, MentorFeedback, MentorshipRequest
)

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1", tags=["Mentorship"])

# Load the ML model globally for efficiency (loads once on startup)
# all-MiniLM-L6-v2 produces 384-dimensional vectors
embed_model = SentenceTransformer('all-MiniLM-L6-v2')

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

# ── Mentor Profile Logic ───────────────────────────────────────────────────

class MentorProfileIn(BaseModel):
    expertise: str
    bio: Optional[str] = None
    years_experience: int = 0

@router.post("/profiles/mentors/", status_code=201)
def create_mentor_profile(
    body: MentorProfileIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.MENTOR:
        raise HTTPException(status_code=403, detail="Only mentors can create a profile.")

    if db.query(Mentor).filter(Mentor.user_id == current_user.id).first():
        raise HTTPException(status_code=409, detail="Mentor profile already exists.")

    # STEP: Generate the semantic vector from the expertise text
    vector_data = embed_model.encode(body.expertise).tolist()

    mentor = Mentor(
        user_id=current_user.id,
        expertise=body.expertise,
        expertise_vector=vector_data,
        bio=body.bio,
        years_experience=body.years_experience,
        is_verified=True # Auto-verified for immediate access
    )
    
    db.add(mentor)
    db.commit()
    db.refresh(mentor)
    return {"mentor_id": str(mentor.id), "message": "AI-indexed profile created."}

# ── Semantic Search Route ──────────────────────────────────────────────────

@router.get("/mentorship/search/")
def search_mentors(
    career_goal: str = Query(..., description="The student's career interest or goal"),
    limit: int = 5,
    db: Session = Depends(get_db)
):
    # 1. Convert the search string into a vector
    search_vector = embed_model.encode(career_goal).tolist()

    # 2. Use PGVector's Cosine Distance operator (<=>) to find matches
    # This finds mentors who ARE conceptually similar even if keywords don't match
    results = (
        db.query(Mentor)
        .filter(Mentor.is_verified == True)
        .order_by(Mentor.expertise_vector.cosine_distance(search_vector))
        .limit(limit)
        .all()
    )

    return [
        {
            "mentor_id": str(m.id),
            "expertise": m.expertise,
            "bio": m.bio,
            "years_experience": m.years_experience,
            "rating": m.rating,
        }
        for m in results
    ]

# ── Availability Management ────────────────────────────────────────────────

class AvailabilityIn(BaseModel):
    day_of_week: int   # 1=Mon, 7=Sun
    start_time: str    # "HH:MM"
    end_time: str      # "HH:MM"

@router.post("/mentorship/availability/", status_code=201)
def set_availability(
    body: AvailabilityIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    mentor = db.query(Mentor).filter(Mentor.user_id == current_user.id).first()
    if not mentor or not mentor.is_verified:
        raise HTTPException(status_code=403, detail="Active mentor profile required.")

    try:
        start = datetime.strptime(body.start_time, "%H:%M").time()
        end = datetime.strptime(body.end_time, "%H:%M").time()
    except ValueError:
        raise HTTPException(status_code=400, detail="Use HH:MM format.")

    slot = MentorAvailability(
        mentor_id=mentor.id,
        day_of_week=body.day_of_week,
        start_time=start,
        end_time=end
    )
    db.add(slot)
    db.commit()
    return {"message": "Availability set successfully."}

# ── Mentorship Requests (The Handshake) ────────────────────────────────────

class RequestIn(BaseModel):
    mentor_id: UUID
    availability_id: UUID
    message: str

@router.post("/mentorship/requests/", status_code=201)
def request_mentorship(
    body: RequestIn,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Only students can request mentorship.")

    # Verify slot availability
    slot = db.query(MentorAvailability).filter(
        MentorAvailability.id == body.availability_id,
        MentorAvailability.is_booked == False
    ).first()
    
    if not slot:
        raise HTTPException(status_code=400, detail="Slot is no longer available.")

    new_request = MentorshipRequest(
        student_id=current_user.id,
        mentor_id=body.mentor_id,
        availability_id=body.availability_id,
        message=body.message
    )
    db.add(new_request)
    db.commit()
    return {"message": "Request sent to mentor."}

# ── WebSocket Chat ──────────────────────────────────────────────────────────

@router.websocket("/mentorship/sessions/{session_id}/chat/")
async def websocket_chat(
    websocket: WebSocket,
    session_id: UUID,
    token: str = Query(...),
    db: Session = Depends(get_db),
):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
    except JWTError:
        await websocket.close(code=1008)
        return

    user = db.query(User).filter(User.email == email).first()
    session = db.query(SessionLog).filter(SessionLog.id == session_id).first()
    
    if not user or not session:
        await websocket.close(code=1008)
        return

    mentor = db.query(Mentor).filter(Mentor.id == session.mentor_id).first()
    is_participant = session.student_id == user.id or (mentor and mentor.user_id == user.id)
    
    if not is_participant:
        await websocket.close(code=1008)
        return

    room = str(session_id)
    await manager.connect(room, websocket)

    try:
        while True:
            data = await websocket.receive_json()
            text = (data.get("message") or "").strip()
            if not text: continue

            msg = ChatMessage(session_id=session_id, sender_id=user.id, message=text)
            db.add(msg)
            db.commit()

            await manager.broadcast(room, {
                "sender_id": str(user.id),
                "message": text,
                "sent_at": datetime.now().isoformat()
            })
    except WebSocketDisconnect:
        manager.disconnect(room, websocket)