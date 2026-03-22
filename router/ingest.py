import os
import tempfile
from fastapi import APIRouter, File, UploadFile, HTTPException, Form, Depends
from pydantic import BaseModel

# LangChain Imports
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import PGVector

# Import the lazy-loaded vector store from main
from main import get_vector_store

# Initialize the router
router = APIRouter(prefix="/api/v1", tags=["Ingestion"])

# --- Pydantic Models ---
class IngestionResponse(BaseModel):
    message: str
    chunks_processed: int
    metadata: dict

# --- Endpoints ---
@router.post("/ingest", response_model=IngestionResponse)
async def ingest_lesson(
    file: UploadFile = File(...),
    class_name: str = Form(...),
    subject: str = Form(...),
    chapter_name: str = Form(...),
    vs: PGVector = Depends(get_vector_store)  # Injects the lazy-loaded vector store
):
    """ Uploads a PDF, chunks it, and saves vectors to Postgres. """
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDFs supported.")

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            tmp.write(await file.read())
            tmp_path = tmp.name
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File error: {str(e)}")

    try:
        loader = PyPDFLoader(tmp_path)
        documents = loader.load()

        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)
        chunks = text_splitter.split_documents(documents)

        for chunk in chunks:
            chunk.metadata.update({
                "class_name": class_name,
                "subject": subject,
                "chapter_name": chapter_name
            })

        vs.add_documents(chunks)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Processing error: {str(e)}")
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)

    return IngestionResponse(
        message="Lesson successfully ingested and vectorized.",
        chunks_processed=len(chunks),
        metadata={"class": class_name, "subject": subject, "chapter": chapter_name}
    )