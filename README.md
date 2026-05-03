# 🎓 AcademyFlow — AI-Powered Student Performance App

> A full-stack mobile application that predicts student academic performance using machine learning, built with **Flutter** (Android) + **Python FastAPI** backend + **Supabase** (PostgreSQL) + deployed on **Render**.

[![Live API](https://img.shields.io/badge/API-Live%20on%20Render-brightgreen)](https://academyflow-mobile-app.onrender.com)
[![Web App](https://img.shields.io/badge/Web-Streamlit%20Live-blue)](https://academyflow.streamlit.app)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter%20(Android)-02569B)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB)](https://python.org)

---

## 📱 What is AcademyFlow?

AcademyFlow started as a **Streamlit ML web app** and evolved into a **complete Android mobile application**. A student enters their study habits — hours studied, previous scores, sleep hours, extracurricular participation, and practice papers — and the app predicts their exam performance score using a trained **Linear Regression** model.

Beyond prediction, the app gives:
- 📊 Peer comparison analytics
- 🗺️ 7-day personalised study roadmap (4 intensity levels: maintain / light / moderate / intensive)
- 🎯 Goal gap analysis
- 📚 Subject priority recommendations with urgency levels
- 💡 Personalised study insights
- ⏱️ Pomodoro study timer
- 📈 Full prediction history (saved to cloud)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Flutter Android App                     │
│  Splash · Login · Signup · Home · Predict · Result       │
│          History · Timer · Grade Calculator              │
└──────────────────────┬──────────────────────────────────┘
                       │ REST API (HTTP/JSON)
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Python FastAPI Backend                      │
│  /api/predict  /api/auth/signup  /api/auth/login         │
│  /api/history  /api/warmup  /health                      │
│                                                          │
│  ┌──────────────┐  ┌─────────────┐  ┌───────────────┐   │
│  │  ml_model.py │  │ database.py │  │ analytics.py  │   │
│  │  (Linear     │  │ (Supabase   │  │ (roadmap,     │   │
│  │  Regression) │  │  REST API)  │  │  insights,    │   │
│  └──────────────┘  └─────────────┘  │  comparisons) │   │
│                                      └───────────────┘   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Supabase (PostgreSQL)                       │
│      students · predictions · goals tables              │
│      Row Level Security — each user sees only           │
│      their own data                                      │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter (Dart), Material Design, Google Fonts |
| Backend API | Python, FastAPI, Uvicorn, Pydantic |
| Machine Learning | Scikit-Learn, Linear Regression, Pandas, NumPy, Joblib |
| Database | Supabase (PostgreSQL) via direct REST API |
| Authentication | JWT tokens, Supabase Auth Admin API |
| Deployment | Docker, Render (auto-deploy on Git push) |
| Version Control | Git, GitHub |
| Web App (v1) | Streamlit, Plotly |

---

## 📂 Project Structure

```
Academyflow-ML-main/
│
├── backend/
│   ├── app/
│   │   ├── main.py           # FastAPI app — all endpoints + keep-alive loop
│   │   ├── ml_model.py       # ML model class (OOP, singleton pattern)
│   │   ├── database.py       # Supabase REST client — auth + CRUD operations
│   │   ├── schemas.py        # Pydantic request/response validation schemas
│   │   └── analytics.py      # Insights, roadmap, peer comparison, priorities
│   ├── Dockerfile            # Docker containerisation
│   ├── render_start.sh       # Render startup script
│   ├── supabase_setup.sql    # Full DB schema with RLS policies
│   └── requirements.txt      # Python dependencies
│
├── mobile/
│   └── lib/
│       ├── main.dart         # App entry, splash animation, auth routing
│       ├── theme.dart        # App-wide dark theme
│       ├── screens/
│       │   ├── home_screen.dart
│       │   ├── login_screen.dart
│       │   ├── signup_screen.dart
│       │   ├── predict_screen.dart
│       │   ├── result_screen.dart
│       │   ├── history_screen.dart
│       │   ├── timer_screen.dart
│       │   └── grade_calculator_screen.dart
│       ├── services/
│       │   └── api_service.dart   # All HTTP calls, auth, keep-alive
│       └── widgets/               # Reusable UI components
│
└── MLmodels/
    ├── enhanced_model.pkl         # Trained Linear Regression model package
    ├── enhanced_model_training.ipynb  # Full training notebook
    └── Student_Performance.csv    # Training dataset
```

---

## 🤖 Machine Learning Model

Three models were trained and compared on the same dataset. Linear Regression came out on top:

| Model | R² Score | MAE | RMSE | CV R² (mean ± std) |
|---|---|---|---|---|
| **Linear Regression** ✅ | **0.9890** | **1.598** | **2.009** | **0.9887 ± 0.0004** |
| Gradient Boosting | 0.9882 | 1.655 | 2.085 | 0.9879 ± 0.0003 |
| Random Forest | 0.9872 | 1.729 | 2.170 | 0.9866 ± 0.0003 |

- **Dataset:** 10,000+ student records
- **Validation:** 5-fold cross-validation with strict train-test separation
- **Serialisation:** Joblib `.pkl` package (includes model, feature names, metrics)

### Engineered Features

On top of the 5 raw inputs, 4 custom features were engineered:

| Feature | Formula | Purpose |
|---|---|---|
| Study Sleep Ratio | `hours_studied / (sleep_hours + 1)` | Balances study vs rest |
| Total Effort | `hours_studied + sample_papers` | Combined effort score |
| Previous Score Normalised | `previous_scores / 100` | Scales score to [0,1] |
| Sleep Efficiency | `sleep_hours × (previous_scores / 100)` | Quality sleep vs baseline |

### Model Input

| Parameter | Range | Description |
|---|---|---|
| hours_studied | 0–12 | Daily study hours |
| previous_scores | 0–100 | Last exam score |
| extracurricular | bool | Activity participation |
| sleep_hours | 4–12 | Nightly sleep hours |
| sample_papers | 0–10 | Practice papers completed |
| target_score (optional) | 0–100 | Goal for gap analysis |

---

## 🔌 API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/` | No | Root — API info |
| GET | `/health` | No | Health check + model status |
| GET | `/api/warmup` | No | Keep-alive ping |
| POST | `/api/predict` | Optional | Predict performance + full analytics |
| POST | `/api/auth/signup` | No | Register new user |
| POST | `/api/auth/login` | No | Login — returns JWT |
| GET | `/api/history` | Yes | User's prediction history |

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
    "status": "GOOD",
    "message": "Strong performance with room to reach excellence!",
    "model_name": "Linear Regression"
  },
  "engineered_features": {
    "study_sleep_ratio": 1.0,
    "total_effort": 12,
    "previous_score_normalized": 0.82,
    "sleep_efficiency": 5.74
  },
  "goal_analysis": {
    "target_score": 90,
    "current_score": 87.4,
    "gap": 2.6,
    "progress_percentage": 97.1,
    "on_track": false
  },
  "weekly_roadmap": [...7 days with focus, tasks, study_hours, intensity, tip...],
  "recommendations": [...],
  "peer_comparison": [...],
  "insights": [...],
  "subject_priorities": [...5 ranked priorities with urgency and action...]
}
```

---

## 📱 App Screens

| Screen | What it does |
|---|---|
| Splash | Animated intro — checks auth state, routes to Login or Home |
| Login | Email + password login, saves JWT to SharedPreferences |
| Signup | Register with name, email, department, year |
| Home | Dashboard with quick action buttons |
| Predict | Input form — sliders for all 5 parameters + optional target |
| Result | Full prediction output — score, grade, roadmap, insights, peer comparison |
| History | All past predictions pulled from Supabase, sorted newest first |
| Timer | Pomodoro study timer |
| Grade Calculator | Utility tool for calculating grades |

---

## ⚙️ Running Locally

### Backend
```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Mac/Linux
pip install -r requirements.txt

# Create .env file:
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your_anon_key
# SUPABASE_SERVICE_KEY=your_service_role_key

uvicorn app.main:app --reload
# API: http://localhost:8000
# Swagger docs: http://localhost:8000/docs
```

### Flutter App
```bash
cd mobile
flutter pub get
# Update lib/services/api_service.dart baseUrl to http://10.0.2.2:8000 for emulator
flutter run
```

### Docker
```bash
cd backend
docker build -t academyflow-api .
docker run -p 8000:8000 --env-file .env academyflow-api
```

---

## 🌐 Deployment

Backend deployed on **Render** via Docker with auto-deploy on every `git push`.

**Cold start prevention (dual keep-alive system):**
- **Backend:** Async self-ping loop in `main.py` — hits `/api/warmup` every 10 minutes
- **Frontend:** Flutter `ApiService.startKeepAlive()` — pings server every 10 minutes while app is open
- Result: Server stays warm, users never wait for cold start

---

## 🗄️ Database Schema

```sql
-- Student profiles (linked to Supabase auth users)
CREATE TABLE students (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    name TEXT NOT NULL,
    department TEXT,
    year INTEGER CHECK (year BETWEEN 1 AND 4),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prediction history
CREATE TABLE predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(id),
    hours_studied INTEGER,
    previous_scores INTEGER,
    extracurricular BOOLEAN,
    sleep_hours INTEGER,
    sample_papers INTEGER,
    predicted_score FLOAT,
    grade TEXT,
    target_score INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Study goals
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(id),
    target_score INTEGER CHECK (target_score BETWEEN 0 AND 100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

Row Level Security is enabled — each user can only read and write their own data.

---

## 🔒 Authentication Flow

1. Signup → Supabase Admin API creates user with auto email confirm
2. Login → returns JWT access token
3. Flutter stores token in `SharedPreferences`
4. Every authenticated request sends `Authorization: Bearer <token>`
5. Backend decodes JWT to extract `user_id` for DB operations
6. Logout clears token from SharedPreferences

---

## 👨‍💻 Built By

**Barani M** — B.Sc. Data Science, Sathyabama University

- 🌐 Portfolio: [lynxofficial7777-hash.github.io](https://lynxofficial7777-hash.github.io)
- 📧 Email: baranimoorthy77@gmail.com
- 💼 LinkedIn: [linkedin.com/in/baranimoorthy77](https://linkedin.com/in/baranimoorthy77)
- 🐙 GitHub: [github.com/lynxofficial7777-hash](https://github.com/lynxofficial7777-hash)

---

## 🌟 Related

- **AcademyFlow Web App (v1):** [academyflow.streamlit.app](https://academyflow.streamlit.app) — The original Streamlit ML web app this project evolved from

---

> Built with Python, Flutter, FastAPI, and a lot of debugging. — Barani M
