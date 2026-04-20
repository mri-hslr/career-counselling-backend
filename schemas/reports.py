from pydantic import BaseModel, Field
from typing import List, Dict

# --- Schema for the 5 Dimensions ---
class TraitAnalysis(BaseModel):
    name: str = Field(..., description="e.g., Resilience, Team Work, Spatial Aptitude")
    score: int = Field(..., ge=1, le=9, description="Score from 1 to 9")
    meaning: str = Field(..., description="1 sentence defining the trait")
    expert_analysis: str = Field(..., description="3-4 sentences interpreting the student's score contextually.")
    development_plan: List[str] = Field(..., description="2-3 actionable bullet points to improve or leverage this trait.")

class DimensionCategory(BaseModel):
    dominant_traits: List[str] = Field(..., description="Top 2-3 traits in this dimension")
    traits: List[TraitAnalysis] = Field(..., description="Detailed breakdown of all traits in this dimension")

class FiveDimensionsReport(BaseModel):
    orientation_style: DimensionCategory
    interest: DimensionCategory
    personality: DimensionCategory
    aptitude: DimensionCategory
    emotional_quotient: DimensionCategory

# --- Schema for Career Matching ---
class CareerMatch(BaseModel):
    career_name: str = Field(..., description="e.g., Computer Application & IT, Defense")
    overall_match_percentage: int = Field(..., ge=0, le=100)
    dimension_scores: Dict[str, int] = Field(..., description="Score out of 100 for each of the 5 dimensions. e.g., {'aptitude': 85, 'personality': 60}")
    justification: str = Field(..., description="2 paragraphs explaining WHY this career fits based on their Profile Data and 5D Psychometric Data.")
    trending_fields: List[str] = Field(..., description="e.g., UI/UX Designer, Web Developer")

class CareerMatchReport(BaseModel):
    recommended_careers: List[CareerMatch]