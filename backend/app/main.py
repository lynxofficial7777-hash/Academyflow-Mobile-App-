"""
AcademyFlow API - FastAPI Backend
Serves the ML model as a REST API for the Flutter mobile app.

Run with: uvicorn app.main:app --reload
"""

import asyncio
from datetime import datetime
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware

from app.schemas import (
    PredictionRequest,
    PredictionResponse,
    PredictionResult,
    EngineeredFeatures,
    GoalAnalysis,
    Recommendation,
    PeerComparison,
    Insight,
    RoadmapDay,
    SubjectPriority,
    HealthResponse,
    SignupRequest,
    LoginRequest,
    AuthResponse,
)
from app.ml_model import model_instance
from app.analytics import (
    get_grade_info,
    get_goal_analysis,
    get_recommendations,
    get_peer_comparison,
    get_insights,
    get_weekly_roadmap,
    get_subject_priorities,
)
from app import database as db


# ══════════════════════════════════════════════════════════════
# SELF-PING KEEP-ALIVE (prevents Render free tier shutdown)
# ══════════════════════════════════════════════════════════════

_keep_alive_task = None

async def _self_ping_loop():
    """Ping our own /api/warmup endpoint every 10 minutes to stay alive on Render."""
    import os
    port = os.environ.get("PORT", "8000")
    url = f"http://0.0.0.0:{port}/api/warmup"
    async with httpx.AsyncClient() as client:
        while True:
            await asyncio.sleep(600)
            try:
                await client.get(url, timeout=10)
                print("[keep-alive] self-ping OK")
            except Exception:
                pass


# ══════════════════════════════════════════════════════════════
# APP SETUP
# ══════════════════════════════════════════════════════════════

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load the ML model and start keep-alive on server start."""
    global _keep_alive_task
    loaded = model_instance.load()
    if not loaded:
        print("WARNING: ML model failed to load!")

    _keep_alive_task = asyncio.create_task(_self_ping_loop())
    yield
    _keep_alive_task.cancel()


app = FastAPI(
    title="AcademyFlow API",
    description="Student Performance Prediction API - Powered by Machine Learning",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ══════════════════════════════════════════════════════════════
# ENDPOINTS
# ══════════════════════════════════════════════════════════════

@app.get("/", tags=["General"])
async def root():
    return {
        "app": "AcademyFlow API",
        "version": "2.0.0",
        "docs": "/docs",
        "message": "Student Performance Prediction API is running!",
    }


@app.get("/health", response_model=HealthResponse, tags=["General"])
async def health_check():
    return HealthResponse(
        status="healthy" if model_instance.model_loaded else "degraded",
        model_loaded=model_instance.model_loaded,
        model_name=model_instance.model_name if model_instance.model_loaded else None,
        version="2.0.0",
    )


@app.get("/api/warmup", tags=["General"])
async def warmup():
    return {"status": "warm", "model_loaded": model_instance.model_loaded}


@app.post("/api/predict", response_model=PredictionResponse, tags=["Prediction"])
async def predict_performance(request: PredictionRequest, authorization: str = Header(None)):
    if not model_instance.model_loaded:
        raise HTTPException(
            status_code=503,
            detail="ML model is not loaded. Please try again later.",
        )

    extra_int = 1 if request.extracurricular else 0

    try:
        prediction = model_instance.predict(
            hours_studied=request.hours_studied,
            previous_scores=request.previous_scores,
            extracurricular=extra_int,
            sleep_hours=request.sleep_hours,
            sample_papers=request.sample_papers,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

    grade_info = get_grade_info(prediction)

    eng = model_instance.calculate_engineered_features(
        request.hours_studied,
        request.previous_scores,
        extra_int,
        request.sleep_hours,
        request.sample_papers,
    )

    response = PredictionResponse(
        prediction=PredictionResult(
            score=round(prediction, 1),
            grade=grade_info["grade"],
            status=grade_info["status"],
            message=grade_info["message"],
            model_name=model_instance.model_name,
        ),
        engineered_features=EngineeredFeatures(
            study_sleep_ratio=round(eng["Study_Sleep_Ratio"], 3),
            total_effort=eng["Total_Effort"],
            previous_score_normalized=eng["Previous_Score_Normalized"],
            sleep_efficiency=eng["Sleep_Efficiency"],
        ),
        peer_comparison=[
            PeerComparison(**comp)
            for comp in get_peer_comparison(
                request.hours_studied,
                request.previous_scores,
                request.extracurricular,
                request.sleep_hours,
                request.sample_papers,
            )
        ],
        insights=[
            Insight(**ins)
            for ins in get_insights(
                request.hours_studied,
                request.previous_scores,
                request.extracurricular,
                request.sleep_hours,
                request.sample_papers,
            )
        ],
        subject_priorities=[
            SubjectPriority(**p)
            for p in get_subject_priorities(
                request.previous_scores,
                request.hours_studied,
                request.sample_papers,
            )
        ],
        timestamp=datetime.now(),
    )

    if request.target_score is not None:
        response.goal_analysis = GoalAnalysis(
            **get_goal_analysis(prediction, request.target_score)
        )
        response.recommendations = [
            Recommendation(**rec)
            for rec in get_recommendations(
                request.hours_studied,
                request.previous_scores,
                request.extracurricular,
                request.sleep_hours,
                request.sample_papers,
                prediction,
                request.target_score,
            )
        ]
        response.weekly_roadmap = [
            RoadmapDay(**day)
            for day in get_weekly_roadmap(
                request.hours_studied,
                request.previous_scores,
                request.extracurricular,
                request.sleep_hours,
                request.sample_papers,
                prediction,
                request.target_score,
            )
        ]

    # Save to history if authenticated
    if authorization:
        try:
            import json, base64
            token = authorization.replace("Bearer ", "")
            payload = json.loads(base64.urlsafe_b64decode(token.split(".")[1] + "=="))
            user_id = payload.get("sub")
            if user_id:
                db.save_prediction(token, user_id, {
                    "hours_studied": request.hours_studied,
                    "previous_scores": request.previous_scores,
                    "extracurricular": extra_int,
                    "sleep_hours": request.sleep_hours,
                    "sample_papers": request.sample_papers,
                    "predicted_score": round(prediction, 1),
                    "grade": grade_info["grade"],
                    "target_score": request.target_score,
                    "input_data": {
                        "hours_studied": request.hours_studied,
                        "previous_scores": request.previous_scores,
                        "sleep_hours": request.sleep_hours,
                    }
                })
        except Exception:
            pass  # Don't fail prediction if history save fails

    return response


# ══════════════════════════════════════════════════════════════
# AUTH ENDPOINTS
# ══════════════════════════════════════════════════════════════

@app.post("/api/auth/signup", response_model=AuthResponse, tags=["Auth"])
async def signup(request: SignupRequest):
    try:
        auth_data = db.signup(request.email, request.password)
        user_id = auth_data["user"]["id"]
        access_token = auth_data["access_token"]

        db.create_student_profile(access_token, user_id, request.name, request.department, request.year)

        return AuthResponse(
            user_id=user_id,
            access_token=access_token,
            message="Signup successful!",
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/auth/login", response_model=AuthResponse, tags=["Auth"])
async def login(request: LoginRequest):
    try:
        auth_data = db.login(request.email, request.password)
        return AuthResponse(
            user_id=auth_data["user"]["id"],
            access_token=auth_data["access_token"],
            message="Login successful!",
        )
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid email or password")


# ══════════════════════════════════════════════════════════════
# HISTORY ENDPOINTS
# ══════════════════════════════════════════════════════════════

@app.get("/api/history", tags=["History"])
async def get_history(authorization: str = Header(...)):
    try:
        token = authorization.replace("Bearer ", "")
        import json, base64
        payload = json.loads(base64.urlsafe_b64decode(token.split(".")[1] + "=="))
        user_id = payload["sub"]
        history = db.get_prediction_history(token, user_id)
        return {"history": history}
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
