# 🎓 AcademyFlow — AI-Powered Student Performance App

> A full-stack mobile application that predicts student academic performance using machine learning, built with **Flutter** (Android) + **Python FastAPI** backend + **Supabase** (PostgreSQL) + deployed on **Render**.

[![Live API](https://img.shields.io/badge/API-Live%20on%20Render-brightgreen)](https://academyflow-ml.onrender.com)
[![Web App](https://img.shields.io/badge/Web-Streamlit%20Live-blue)](https://academyflow.streamlit.app)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter%20(Android)-02569B)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB)](https://python.org)

---

## 📱 What is AcademyFlow?

AcademyFlow started as a **Streamlit ML web app** and evolved into a **complete Android mobile application**. A student enters their study habits — hours studied, previous scores, sleep hours, extracurricular participation, and practice papers — and the app predicts their performance score using a trained Random Forest ML model.

Beyond prediction, the app gives:
- 📊 Peer comparison analytics
- 🗺️ 7-day personalised study roadmap
- 🎯 Goal gap analysis
- 📚 Subject priority recommendations
- 💡 Personalised study insights
- ⏱️ Pomodoro study timer
- 📈 Full prediction history

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Flutter Android App                  │
│   Login · Signup · Predict · Result · History        │
│         Timer · Grade Calculator · Home              │
└────────────────────┬────────────────────────────────┘
                     │ REST API (HTTP/JSON)
                     ▼
┌─────────────────────────────────────────────────────┐
│              FastAPI Backend (Python)                │
│   /api/predict  /api/auth/signup  /api/auth/login    │
│   /api/history  /api/warmup  /health                 │
│                                                      │
│   ┌─────────────┐   ┌────────────┐  ┌────────────┐  │
│   │  ml_model   │   │  database  │  │ analytics  │  │
│   │ (Random     │   │ (Supabase  │  │ (roadmap,  │  │
│   │  Forest)    │   │  REST API) │  │  insights) │  │
│   └─────────────┘   └────────────┘  └────────────┘  │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│            Supabase (PostgreSQL)                     │
│     students · predictions · goals tables           │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter (Dart), Material Design, Google Fonts |
| Backend API | Python, FastAPI, Uvicorn, Pydantic |
| Machine Learning | Scikit-Learn, Random Forest, Pandas, NumPy, Joblib |
| Database | Supabase (PostgreSQL) via REST API |
| Authentication | JWT tokens, Supabase Auth Admin API |
| Deployment | Docker, Render (auto-deploy on Git push) |
| Version Control | Git, GitHub |
| Web App (v1) | Streamlit, Plotly |

---

## 📂 Project Structure

```
Academyflow-ML-main/
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI app, all endpoints, keep-alive loop
│   │   ├── ml_model.py      # ML model loader + prediction engine (OOP)
│   │   ├── database.py      # Supabase REST API client (auth, CRUD)
│   │   ├── schemas.py       # Pydantic request/response schemas
│   │   └── analytics.py     # Roadmap, insights, recommendations logic
│   ├── Dockerfile           # Docker containerisation
│   ├── render_start.sh      # Render startup script
│   └── requirements.txt     # Python dependencies
│
├── mobile/
│   └── lib/
│       ├── main.dart        # App entry point, routing
│       ├── theme.dart       # App-wide theme and styling
│       ├── screens/
│       │   ├── home_screen.dart
│       │   ├── login_screen.dart
│       │   ├── signup_screen.dart
│       │   ├── predict_screen.dart
│       │   ├── result_screen.dart
│       │   ├── history_screen.dart
│       │   ├── timer_screen.dart
│       │   └── grade_calculator_screen.dart
│       ├── services/        # API service layer
│       └── widgets/         # Reusable UI components
│
└── MLmodels/
    ├── enhanced_model.pkl   # Trained Random Forest model
    └── BARANI_CONTRIBUTION.md
```

---

## 🤖 Machine Learning Model

| Detail | Value |
|---|---|
| Algorithm | Random Forest |
| Accuracy | **99.14%** |
| Training Records | 10,000+ student records |
| Validation | 5-fold cross-validation |
| Evaluation Metrics | R² = 0.9914, MAE = 1.38, RMSE = 1.81 |
| Serialisation | Joblib (.pkl) |

### Engineered Features

| Feature | Formula |
|---|---|
| Study Sleep Ratio | `hours_studied / (sleep_hours + 1)` |
| Total Effort | `hours_studied + sample_papers` |
| Previous Score Normalised | `previous_scores / 100` |
| Sleep Efficiency | `sleep_hours × (previous_scores / 100)` |

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Root — API info |
| GET | `/health` | Health check + model status |
| GET | `/api/warmup` | Keep-alive ping endpoint |
| POST | `/api/predict` | Predict student performance |
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/login` | Login and get JWT token |
| GET | `/api/history` | Get user's prediction history |

### Sample Prediction Request
```json
POST /api/predict
{
  "hours_studied": 7,
  "previous_scores": 82,
  "extracurricular": true,
  "sleep_hours": 7,
  "sample_papers": 5,
  "target_score": 90
}
```

### Sample Response (truncated)
```json
{
  "prediction": {
    "score": 87.4,
    "grade": "good",
    "status": "Good Performance",
    "message": "You're performing well! Keep pushing.",
    "model_name": "Random Forest"
  },
  "goal_analysis": {
    "target_score": 90,
    "current_score": 87.4,
    "gap": 2.6,
    "progress_percentage": 97.1,
    "on_track": true
  },
  "weekly_roadmap": [...],
  "recommendations": [...],
  "insights": [...]
}
```

---

## 📱 App Screens

| Screen | Description |
|---|---|
| Splash | App intro with loading animation |
| Login | Email + password login with JWT session |
| Signup | Register with name, email, department, year |
| Home | Dashboard with quick actions |
| Predict | Input form for study habit data |
| Result | Full prediction with roadmap, insights, comparisons |
| History | Previous predictions with scores and grades |
| Timer | Pomodoro study timer |
| Grade Calculator | Utility tool for grade calculation |

---

## ⚙️ Running Locally

### Backend
```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt

# Create .env file with:
# SUPABASE_URL=your_url
# SUPABASE_ANON_KEY=your_key
# SUPABASE_SERVICE_KEY=your_service_key

uvicorn app.main:app --reload
# API runs at http://localhost:8000
# Docs at http://localhost:8000/docs
```

### Flutter App
```bash
cd mobile
flutter pub get
flutter run
```

### Docker (Backend)
```bash
cd backend
docker build -t academyflow-api .
docker run -p 8000:8000 --env-file .env academyflow-api
```

---

## 🌐 Deployment

The backend is deployed on **Render** using Docker.

- Every `git push` to main triggers an automatic redeploy
- A dual keep-alive system prevents cold starts on Render's free tier:
  - **Internal:** Async self-ping loop hitting `/api/warmup` every 10 minutes
  - **External:** Cron job configured separately hitting the same endpoint

---

## 🗄️ Database Schema (Supabase)

```sql
-- Students table
students (id, name, department, year, created_at)

-- Predictions table
predictions (id, student_id, hours_studied, previous_scores,
             extracurricular, sleep_hours, sample_papers,
             predicted_score, grade, target_score, created_at)

-- Goals table
goals (id, student_id, target_score, is_active, created_at)
```

---

## 🔒 Authentication Flow

1. User signs up → Supabase Admin API creates user (auto email confirm)
2. Immediate login → returns JWT access token
3. Token stored in Flutter via `SharedPreferences`
4. All authenticated requests send `Authorization: Bearer <token>`
5. Backend decodes JWT to extract `user_id` for DB operations

---

## 👨‍💻 Built By

**Barani M**
- 🌐 Portfolio: [lynxofficial7777-hash.github.io](https://lynxofficial7777-hash.github.io)
- 📧 Email: baranimoorthy77@gmail.com
- 💼 LinkedIn: [linkedin.com/in/baranimoorthy77](https://linkedin.com/in/baranimoorthy77)
- 🐙 GitHub: [github.com/lynxofficial7777-hash](https://github.com/lynxofficial7777-hash)

---

## 🌟 Related Projects

- **AcademyFlow Web App (v1):** [academyflow.streamlit.app](https://academyflow.streamlit.app) — The original Streamlit ML web application

---

> Built with Python, Flutter, and a lot of debugging. — Barani M
