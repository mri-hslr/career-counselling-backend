# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Career Counseling AI API — a FastAPI backend that uses LLMs (DeepSeek, Groq) and RAG to evaluate students' aptitude, personality, academic performance, and lifestyle, then recommends personalized career paths.

## Commands

```bash
# Start the API server
uvicorn main:app --reload

# Initialize/reset the database schema
python init_db.py

# Populate initial data
python populate.py
```

## Architecture

### Request Flow

1. **Auth**: `POST /api/v1/auth/register` → `POST /api/v1/auth/login` → JWT bearer token
2. **Assessments**: Frontend fetches questions via `GET /api/v1/assessments/questions/{module_name}`, submits answers via `POST /api/v1/assessments/submit-generic` which writes to JSONB columns on the `users` table
3. **AI Recommendations**: `POST /api/v1/ai/recommend` (requires JWT) — collects all JSONB fields from the user row and sends to DeepSeek LLM
4. **Roadmap**: `GET /api/v1/career/roadmap` — sends a hardcoded career target to Groq LLM

### User Data Model

The `users` table uses JSONB columns to store all assessment data: `academic_data`, `apti_data`, `personality_data`, `lifestyle_data`, `financial_data`, `passion_strength_data`, `aspiration_data`, `career_interest_data`. There are also separate normalized profile tables in `models/compass.py` used only by the question templates in `ques.py`.

### Key Files

- `main.py` — FastAPI app, CORS, all router registrations
- `core/database.py` — SQLAlchemy engine (Neon PostgreSQL), `get_db` dependency
- `core/security.py` — bcrypt hashing, JWT creation/validation
- `api/deps.py` — `get_current_user` dependency (validates JWT, returns User)
- `api/v1/submit.py` — universal JSONB writer; uses raw psycopg2 with `COLUMN_MAPPING` dict to prevent SQL injection via column name
- `api/v1/ques.py` — question fetcher; `MODULE_REGISTRY` maps module names to DB tables/UUIDs
- `router/personality.py` — Big Five personality engine with hardcoded questions and reverse-scoring logic

### Two Separate DB Access Patterns

- **SQLAlchemy ORM** (`core/database.py`) used in auth, career recommendation, and protected routes
- **Raw psycopg2** (`os.getenv("DATABASE_URL")`) used in `submit.py`, `ques.py`, and `aptitude.py` — these re-read `DATABASE_URL` independently

### LLM Integrations

- **DeepSeek** (`career.py`): Uses `ChatOpenAI` pointed at `https://api.deepseek.com`, model `deepseek-chat`
- **Groq** (`roadmap.py`): Uses `ChatOpenAI` pointed at `https://api.groq.com/openai/v1`, model `llama-3.3-70b-versatile`
- Both use `PydanticOutputParser` for structured JSON output

## Environment Variables Required

```
DATABASE_URL=postgresql+psycopg2://...
DEEPSEEK_API_KEY=sk-...
GROQ_API_KEY=gsk_...
JWT_SECRET_KEY=...  # optional, has insecure default
```
