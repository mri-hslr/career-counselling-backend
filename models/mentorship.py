import uuid
from sqlalchemy import Column, String, Float, Boolean, ForeignKey, DateTime, Integer, Text, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from pgvector.sqlalchemy import Vector # Required for semantic search
from core.database import Base

# ── MENTOR PROFILE ──────────────────────────────────────────────────────────

class Mentor(Base):
    __tablename__ = "mentors"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    
    # Core Expertise Fields
    expertise = Column(String, nullable=False) # e.g., "Backend Development"
    
    # AI Search Vector (384 dimensions for all-MiniLM-L6-v2)
    # This replaces expertise_hash
    expertise_vector = Column(Vector(384)) 
    
    # Profile Details
    bio = Column(Text)
    years_experience = Column(Integer, default=0)
    rating = Column(Float, default=0.0)
    
    # Verification (Auto-set to True for immediate access)
    is_verified = Column(Boolean, default=True, server_default="true")
    
    # Relationships
    user = relationship("User", back_populates="mentor_profile")
    availability = relationship("MentorAvailability", backref="mentor", cascade="all, delete-orphan")

# ── AVAILABILITY SLOTS ──────────────────────────────────────────────────────

class MentorAvailability(Base):
    __tablename__ = "mentor_availability"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    mentor_id = Column(UUID(as_uuid=True), ForeignKey("mentors.id", ondelete="CASCADE"))
    
    day_of_week = Column(Integer) # 1=Mon, 7=Sun
    start_time = Column(Time)
    end_time = Column(Time)
    is_booked = Column(Boolean, default=False)

# ── MENTORSHIP REQUESTS ─────────────────────────────────────────────────────

class MentorshipRequest(Base):
    __tablename__ = "mentorship_requests"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    mentor_id = Column(UUID(as_uuid=True), ForeignKey("mentors.id", ondelete="CASCADE"))
    availability_id = Column(UUID(as_uuid=True), ForeignKey("mentor_availability.id", ondelete="CASCADE"))
    
    message = Column(Text) 
    status = Column(String, default="pending") # pending, approved, rejected
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())

# ── SESSION & CHAT ──────────────────────────────────────────────────────────

class SessionLog(Base):
    __tablename__ = "sessions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    mentor_id = Column(UUID(as_uuid=True), ForeignKey("mentors.id", ondelete="CASCADE"))
    
    scheduled_at = Column(DateTime(timezone=True), nullable=False)
    duration_minutes = Column(Integer, default=60)
    status = Column(String, default="scheduled") 
    meeting_url = Column(String)

class ChatMessage(Base):
    __tablename__ = "chat_messages"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey("sessions.id", ondelete="CASCADE"))
    sender_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    
    message = Column(Text, nullable=False)
    sent_at = Column(DateTime(timezone=True), server_default=func.now())

# ── FEEDBACK SYSTEMS ────────────────────────────────────────────────────────

class MentorFeedback(Base):
    __tablename__ = "mentor_feedback"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey("sessions.id", ondelete="CASCADE"))
    mentor_id = Column(UUID(as_uuid=True), ForeignKey("mentors.id", ondelete="CASCADE"))
    student_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    
    notes = Column(Text) 
    action_items = Column(Text) 
    submitted_at = Column(DateTime(timezone=True), server_default=func.now())

class ParentFeedback(Base):
    __tablename__ = "parent_feedback"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    parent_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    student_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    
    behavior_insights = Column(Text)
    study_habits = Column(Text)
    logged_at = Column(DateTime(timezone=True), server_default=func.now())

class ParentStudentLink(Base):
    __tablename__ = "parent_student_links"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    parent_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    student_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    linked_at = Column(DateTime(timezone=True), server_default=func.now())