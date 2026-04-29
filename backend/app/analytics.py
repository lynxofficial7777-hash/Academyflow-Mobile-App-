"""
Analytics engine - generates insights, recommendations, comparisons, and roadmaps.
"""

from functools import lru_cache


def get_grade_info(prediction: float) -> dict:
    """Determine grade class, status, and message from prediction score."""
    if prediction >= 85:
        return {
            "grade": "excellent",
            "status": "EXCELLENT",
            "message": "Outstanding performance! Keep up the excellent work!",
        }
    elif prediction >= 70:
        return {
            "grade": "good",
            "status": "GOOD",
            "message": "Strong performance with room to reach excellence!",
        }
    elif prediction >= 50:
        return {
            "grade": "average",
            "status": "AVERAGE",
            "message": "Decent performance. Increase efforts to improve further.",
        }
    else:
        return {
            "grade": "poor",
            "status": "NEEDS IMPROVEMENT",
            "message": "Focus on fundamentals and increase study time.",
        }


def get_goal_analysis(prediction: float, target_score: int) -> dict:
    """Calculate gap between current prediction and target score."""
    gap = target_score - prediction
    progress_pct = min((prediction / target_score) * 100, 100)
    return {
        "target_score": target_score,
        "current_score": round(prediction, 1),
        "gap": round(max(gap, 0), 1),
        "progress_percentage": round(progress_pct, 1),
        "on_track": prediction >= target_score,
    }


def get_recommendations(
    hours_studied: int,
    previous_scores: int,
    extracurricular: bool,
    sleep_hours: int,
    sample_papers: int,
    prediction: float,
    target_score: int,
) -> list[dict]:
    """Generate personalized recommendations to reach the target score."""
    if prediction >= target_score:
        return []

    recommendations = []

    if hours_studied < 8:
        recommendations.append(
            {
                "icon": "book",
                "title": "Increase Study Time",
                "description": f"Try studying {min(hours_studied + 2, 10)} hours/day to boost performance",
            }
        )

    if sample_papers < 7:
        recommendations.append(
            {
                "icon": "document",
                "title": "Practice More Papers",
                "description": f"Complete {min(sample_papers + 3, 10)} practice papers for better preparation",
            }
        )

    if sleep_hours < 7:
        recommendations.append(
            {
                "icon": "moon",
                "title": "Improve Sleep",
                "description": "Aim for 7-8 hours of sleep for better memory retention",
            }
        )

    if not extracurricular:
        recommendations.append(
            {
                "icon": "trophy",
                "title": "Join Activities",
                "description": "Extracurricular activities correlate with better performance",
            }
        )

    return recommendations[:3]


def get_peer_comparison(
    hours_studied: int,
    previous_scores: int,
    extracurricular: bool,
    sleep_hours: int,
    sample_papers: int,
) -> list[dict]:
    """Compare student scores against class averages."""
    # Class averages (same as your Streamlit app)
    avg_scores = [60, 70, 65, 60, 50]

    student_scores = [
        (hours_studied / 12) * 100,
        previous_scores,
        (sleep_hours / 12) * 100,
        (sample_papers / 10) * 100,
        100 if extracurricular else 20,
    ]

    categories = ["Study Time", "Academic", "Sleep", "Practice", "Activities"]

    comparisons = []
    for cat, student, avg in zip(categories, student_scores, avg_scores):
        diff = student - avg
        comparisons.append(
            {
                "category": cat,
                "student_score": round(student, 1),
                "class_average": avg,
                "difference": round(diff, 1),
                "is_strength": diff > 10,
            }
        )

    return comparisons


def get_insights(
    hours_studied: int,
    previous_scores: int,
    extracurricular: bool,
    sleep_hours: int,
    sample_papers: int,
) -> list[dict]:
    """Generate personalized study insights. Same logic as your Tab 4."""
    insights = []

    # Study time insights
    if hours_studied >= 8:
        insights.append(
            {
                "icon": "book",
                "title": "Excellent Study Commitment",
                "description": f"Your {hours_studied} hours of daily study is exceptional. Maintain this consistency!",
                "level": "success",
            }
        )
    elif hours_studied >= 5:
        insights.append(
            {
                "icon": "book-open",
                "title": "Good Study Routine",
                "description": f"{hours_studied} hours is solid, but pushing to 7-8 hours can significantly boost results.",
                "level": "info",
            }
        )
    else:
        insights.append(
            {
                "icon": "clock",
                "title": "Increase Study Time",
                "description": f"Only {hours_studied} hours/day may not be enough. Try gradually increasing to 6-7 hours.",
                "level": "warning",
            }
        )

    # Sleep insights
    if 7 <= sleep_hours <= 9:
        insights.append(
            {
                "icon": "moon",
                "title": "Optimal Sleep Schedule",
                "description": f"{sleep_hours} hours of sleep is perfect for memory consolidation and cognitive function.",
                "level": "success",
            }
        )
    elif sleep_hours < 7:
        insights.append(
            {
                "icon": "moon",
                "title": "Sleep More",
                "description": f"{sleep_hours} hours may not be enough. Aim for 7-8 hours to improve retention and focus.",
                "level": "warning",
            }
        )
    else:
        insights.append(
            {
                "icon": "clock",
                "title": "Too Much Sleep?",
                "description": f"{sleep_hours} hours might be excessive. 7-8 hours is optimal for most students.",
                "level": "info",
            }
        )

    # Practice insights
    if sample_papers >= 7:
        insights.append(
            {
                "icon": "document",
                "title": "Excellent Exam Prep",
                "description": f"{sample_papers} practice papers shows strong preparation. This is a top predictor of success!",
                "level": "success",
            }
        )
    elif sample_papers >= 4:
        insights.append(
            {
                "icon": "document",
                "title": "Good Practice Routine",
                "description": f"{sample_papers} papers is decent. Push to 7-8 for maximum exam confidence.",
                "level": "info",
            }
        )
    else:
        insights.append(
            {
                "icon": "document",
                "title": "Practice More",
                "description": f"Only {sample_papers} papers practiced. This is crucial - aim for at least 6-7 before exams.",
                "level": "warning",
            }
        )

    # Extracurricular insights
    if extracurricular:
        insights.append(
            {
                "icon": "trophy",
                "title": "Well-Rounded Profile",
                "description": "Extracurricular participation builds discipline and correlates with higher academic performance.",
                "level": "success",
            }
        )
    else:
        insights.append(
            {
                "icon": "target",
                "title": "Consider Activities",
                "description": "Joining clubs or sports can improve time management and overall academic outcomes.",
                "level": "info",
            }
        )

    # Previous scores insight
    if previous_scores >= 85:
        insights.append(
            {
                "icon": "star",
                "title": "Strong Academic Foundation",
                "description": f"{previous_scores}% shows excellent prior knowledge. Build on this momentum!",
                "level": "success",
            }
        )
    elif previous_scores >= 70:
        insights.append(
            {
                "icon": "chart",
                "title": "Solid Performance",
                "description": f"{previous_scores}% is good. Focus on weak topics to push into the 85+ range.",
                "level": "info",
            }
        )
    else:
        insights.append(
            {
                "icon": "trending-down",
                "title": "Foundation Building Needed",
                "description": f"{previous_scores}% suggests knowledge gaps. Consider focused revision on core topics.",
                "level": "warning",
            }
        )

    return insights


def get_weekly_roadmap(
    hours_studied: int,
    previous_scores: int,
    extracurricular: bool,
    sleep_hours: int,
    sample_papers: int,
    prediction: float,
    target_score: int,
) -> list[dict]:
    """Generate a 7-day study roadmap to close the gap to target score."""
    gap = target_score - prediction

    if gap <= 0:
        intensity = "maintain"
    elif gap <= 10:
        intensity = "light"
    elif gap <= 20:
        intensity = "moderate"
    else:
        intensity = "intensive"

    rec_hours = min(hours_studied + (2 if gap > 15 else 1 if gap > 5 else 0), 10)
    rec_papers = min(sample_papers + 1, 10)

    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    plans = {
        "maintain": [
            {"focus": "Review & Consolidate", "tasks": ["Revise last week's notes", "Solve 1 practice paper", "Light reading"], "study_hours": rec_hours, "tip": "Consistency is key — keep your routine steady."},
            {"focus": "Deep Practice", "tasks": ["Focus on your weakest topic", "Timed mock test", "Review mistakes"], "study_hours": rec_hours, "tip": "Targeted practice prevents regression."},
            {"focus": "Concept Strengthening", "tasks": ["Mind-map key concepts", "Teach a topic to yourself", "Formula revision"], "study_hours": rec_hours, "tip": "Teaching is the best way to solidify understanding."},
            {"focus": "Problem Solving", "tasks": ["Solve past exam questions", "Focus on high-weightage topics", "Note common patterns"], "study_hours": rec_hours, "tip": "Pattern recognition is a skill — practice it."},
            {"focus": "Speed & Accuracy", "tasks": ["Timed practice session", "Identify slow areas", "Quick revision"], "study_hours": max(rec_hours - 1, 2), "tip": "Speed comes from confidence — confidence from practice."},
            {"focus": "Full Mock Test", "tasks": ["Complete full-length mock exam", "Strict time limit", "Self-evaluate"], "study_hours": rec_hours + 1, "tip": "Simulate real exam conditions every week."},
            {"focus": "Rest & Light Review", "tasks": ["Light reading only", "Organize notes", "Plan next week"], "study_hours": max(rec_hours - 2, 2), "tip": "Rest is part of the plan — your brain consolidates during sleep."},
        ],
        "light": [
            {"focus": "Identify Weak Areas", "tasks": ["Take a diagnostic test", "List topics below 70%", "Create a priority list"], "study_hours": rec_hours, "tip": "You can't fix what you don't measure."},
            {"focus": "Core Concept Review", "tasks": ["Study top 2 weak topics", "Make summary notes", "Solve 5 problems per topic"], "study_hours": rec_hours, "tip": "Focus beats breadth — go deep on weak areas."},
            {"focus": "Practice Papers", "tasks": [f"Complete {rec_papers} practice papers", "Time yourself strictly", "Review every wrong answer"], "study_hours": rec_hours, "tip": "Each wrong answer is a free lesson."},
            {"focus": "Formula & Theory Drill", "tasks": ["Revise all formulas", "Write them from memory", "Apply in 10 problems each"], "study_hours": rec_hours, "tip": "Formulas under pressure require muscle memory."},
            {"focus": "Mixed Topic Practice", "tasks": ["Solve mixed-topic questions", "Focus on application", "Note time per question"], "study_hours": rec_hours, "tip": "Exams mix topics — your practice should too."},
            {"focus": "Mock Exam Day", "tasks": ["Full mock under exam conditions", "No phone, strict timing", "Score and analyze"], "study_hours": rec_hours + 1, "tip": "Treat every mock like the real thing."},
            {"focus": "Review & Plan", "tasks": ["Review mock results", "Update weak topic list", "Plan next week"], "study_hours": max(rec_hours - 1, 3), "tip": "Weekly review keeps you on track."},
        ],
        "moderate": [
            {"focus": "Emergency Diagnosis", "tasks": ["Full diagnostic test", "Rank all topics by score", "Create urgent priority list"], "study_hours": rec_hours, "tip": "Clarity on where you stand is the first step."},
            {"focus": "High-Priority Topic 1", "tasks": [f"Study weakest topic for {rec_hours}h", "Complete 10 problems", "Summarize in your own words"], "study_hours": rec_hours, "tip": "Attack your biggest weakness first."},
            {"focus": "High-Priority Topic 2", "tasks": ["Study 2nd weak topic", "Solve past exam questions", "Create a cheat sheet"], "study_hours": rec_hours, "tip": "Cheat sheets force you to distill what matters."},
            {"focus": "Intensive Practice", "tasks": [f"Complete {rec_papers} timed papers", "Focus on accuracy first", "Review all errors"], "study_hours": rec_hours + 1, "tip": "Accuracy before speed — rushing creates bad habits."},
            {"focus": "Revision Sprint", "tasks": ["Rapid revision of all topics", "Use your summary notes", "Solve 3 problems per topic"], "study_hours": rec_hours, "tip": "Spaced repetition boosts retention."},
            {"focus": "Full Mock + Analysis", "tasks": ["Full mock exam", "Detailed error analysis", "Categorize: concept vs careless mistakes"], "study_hours": rec_hours + 1, "tip": "Categorizing errors helps you fix the right problem."},
            {"focus": "Targeted Fixes", "tasks": ["Fix concept errors from mock", "Re-solve wrong questions", "Update plan for next week"], "study_hours": rec_hours, "tip": "The goal is to learn from every mistake."},
        ],
        "intensive": [
            {"focus": "Crisis Assessment", "tasks": ["Full diagnostic across all topics", "Identify top 3 critical gaps", "Set daily micro-goals"], "study_hours": rec_hours, "tip": "Big gaps require structured urgency — not panic."},
            {"focus": "Critical Topic 1", "tasks": [f"Deep study of weakest topic for {rec_hours+1}h", "Watch explanations if needed", "Solve 15 problems"], "study_hours": rec_hours + 1, "tip": "One topic mastered beats five topics half-learned."},
            {"focus": "Critical Topic 2", "tasks": ["Deep study of 2nd weakest topic", "Solve past exam questions", "Teach it back to yourself"], "study_hours": rec_hours + 1, "tip": "If you can explain it simply, you understand it deeply."},
            {"focus": "Topic 3 + Revision", "tasks": ["Study 3rd weak topic", "Quick revision of topics 1 & 2", f"Complete {rec_papers} practice papers"], "study_hours": rec_hours + 1, "tip": "Revisiting earlier topics prevents forgetting."},
            {"focus": "Intensive Mock Practice", "tasks": ["2 full timed mock papers", "Strict exam conditions", "Detailed error log"], "study_hours": rec_hours + 2, "tip": "Volume of quality practice is what closes big gaps."},
            {"focus": "Error Elimination Day", "tasks": ["Re-study every error from mocks", "Re-solve all wrong questions", "Build a personal mistake list"], "study_hours": rec_hours + 1, "tip": "Your mistake list is your most valuable study tool."},
            {"focus": "Final Sprint + Rest", "tasks": ["Quick revision of all summaries", "Light practice only", "Sleep 8 hours — no exceptions"], "study_hours": max(rec_hours - 1, 3), "tip": "The last day before an exam should be light — trust your preparation."},
        ],
    }

    roadmap = []
    for i, day in enumerate(days):
        plan = plans[intensity][i]
        roadmap.append({
            "day": day,
            "day_number": i + 1,
            "focus": plan["focus"],
            "tasks": plan["tasks"],
            "study_hours": plan["study_hours"],
            "tip": plan["tip"],
            "intensity": intensity,
        })

    return roadmap


def get_subject_priorities(
    previous_scores: int,
    hours_studied: int,
    sample_papers: int,
) -> list[dict]:
    """
    Generate a prioritized list of study areas based on student profile.
    Returns subjects ranked by urgency with specific action items.
    """
    priorities = []

    # Score-based academic priority
    if previous_scores < 60:
        priorities.append({
            "rank": 1,
            "area": "Core Subject Fundamentals",
            "urgency": "critical",
            "reason": f"Previous score of {previous_scores}% indicates foundational gaps that must be addressed first.",
            "action": "Spend 40% of study time on basic concepts before attempting advanced problems.",
            "time_allocation": "40%",
        })
    elif previous_scores < 75:
        priorities.append({
            "rank": 1,
            "area": "Weak Topic Identification",
            "urgency": "high",
            "reason": f"Score of {previous_scores}% suggests specific topic weaknesses rather than broad gaps.",
            "action": "Take a diagnostic test to pinpoint exact weak areas and focus there.",
            "time_allocation": "35%",
        })
    else:
        priorities.append({
            "rank": 1,
            "area": "Advanced Problem Solving",
            "urgency": "medium",
            "reason": f"Strong base score of {previous_scores}% — focus on harder problem types to push higher.",
            "action": "Solve high-difficulty past exam questions and challenge yourself with timed tests.",
            "time_allocation": "30%",
        })

    # Practice paper priority
    if sample_papers < 4:
        priorities.append({
            "rank": 2,
            "area": "Exam Practice & Mock Tests",
            "urgency": "critical",
            "reason": f"Only {sample_papers} practice papers completed — exam familiarity is critically low.",
            "action": "Complete at least 2 full mock papers per week under timed conditions.",
            "time_allocation": "30%",
        })
    elif sample_papers < 7:
        priorities.append({
            "rank": 2,
            "area": "Mock Test Frequency",
            "urgency": "high",
            "reason": f"{sample_papers} papers done — good start but needs more volume for exam confidence.",
            "action": "Increase to 3 mock papers per week, focusing on time management.",
            "time_allocation": "25%",
        })
    else:
        priorities.append({
            "rank": 2,
            "area": "Mock Test Quality Review",
            "urgency": "medium",
            "reason": f"Good volume of {sample_papers} papers — now focus on quality of review over quantity.",
            "action": "Spend equal time reviewing mocks as taking them. Build an error log.",
            "time_allocation": "20%",
        })

    # Study hours priority
    if hours_studied < 4:
        priorities.append({
            "rank": 3,
            "area": "Study Time Management",
            "urgency": "critical",
            "reason": f"Only {hours_studied}h/day is insufficient for meaningful progress.",
            "action": "Use time-blocking: schedule fixed study slots and treat them like classes.",
            "time_allocation": "Build to 6h/day",
        })
    elif hours_studied < 7:
        priorities.append({
            "rank": 3,
            "area": "Study Efficiency",
            "urgency": "medium",
            "reason": f"{hours_studied}h/day is decent — focus on quality over quantity.",
            "action": "Use Pomodoro technique (25 min focus + 5 min break) to maximize retention.",
            "time_allocation": "Optimize current hours",
        })
    else:
        priorities.append({
            "rank": 3,
            "area": "Revision Strategy",
            "urgency": "low",
            "reason": f"Strong {hours_studied}h/day commitment — ensure you're revising, not just reading.",
            "action": "Dedicate last 30 min of each session to active recall — close notes and recall key points.",
            "time_allocation": "15%",
        })

    # Always add these two
    priorities.append({
        "rank": 4,
        "area": "Note Organization & Summaries",
        "urgency": "medium",
        "reason": "Well-organized notes reduce revision time by 40% and improve recall during exams.",
        "action": "Create 1-page summary sheets for each topic. Review them every Sunday.",
        "time_allocation": "10%",
    })

    priorities.append({
        "rank": 5,
        "area": "Health & Sleep Optimization",
        "urgency": "medium",
        "reason": "Sleep is when your brain consolidates learning. Skipping it wastes your study hours.",
        "action": "Maintain 7-8 hours sleep. Avoid screens 30 min before bed. Exercise 3x/week.",
        "time_allocation": "Non-negotiable",
    })

    return priorities
