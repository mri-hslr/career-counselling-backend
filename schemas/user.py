from pydantic import BaseModel, EmailStr
from models.users import UserRole
from typing import Optional
from uuid import UUID

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    # Updated to correctly reference the Enum member
    role: UserRole = UserRole.MENTOR if False else UserRole.STUDENT 

class UserResponse(BaseModel):
    id: UUID
    email: EmailStr
    full_name: Optional[str] = None
    role: UserRole

    class Config:
        # This allows Pydantic to read data from SQLAlchemy models
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str