from datetime import datetime, timezone

from providers.database import get_conn, init_db, Lesson, ActiveLesson, CompletionResult

SEED_LESSONS = [
    {
        "id": "restaurant",
        "title": "Restaurant Role-Play",
        "description": "Order food, ask for the bill, and tip the waiter",
        "language": "es",
        "category": "roleplay",
        "difficulty": 2,
        "scenario": "restaurant",
        "xp_reward": 15,
        "prompt_template": (
            "You are a waiter at a Spanish restaurant called 'El Rincón'. "
            "Greet the customer warmly, recommend today's specials, "
            "help them order, and bring the check when they ask. "
            "Stay in character throughout."
        ),
    },
    {
        "id": "airport",
        "title": "Airport Conversation",
        "description": "Check in, ask for gate info, and board your flight",
        "language": "es",
        "category": "roleplay",
        "difficulty": 3,
        "scenario": "airport",
        "xp_reward": 20,
        "prompt_template": (
            "You are an airport check-in agent at Madrid-Barajas. "
            "Ask for their passport, check their luggage, "
            "tell them the gate and boarding time. "
            "Stay in character throughout."
        ),
    },
    {
        "id": "shopping",
        "title": "Shopping Trip",
        "description": "Ask about prices, sizes, and buy something",
        "language": "es",
        "category": "roleplay",
        "difficulty": 2,
        "scenario": "shopping",
        "xp_reward": 15,
        "prompt_template": (
            "You are a shop assistant in a Spanish clothing store. "
            "Help the customer find what they need, suggest sizes, "
            "and ring up their purchase. Stay in character throughout."
        ),
    },
    {
        "id": "hotel",
        "title": "Hotel Check-In",
        "description": "Check in, ask about amenities, and order room service",
        "language": "es",
        "category": "roleplay",
        "difficulty": 2,
        "scenario": "hotel",
        "xp_reward": 15,
        "prompt_template": (
            "You are a hotel receptionist in Barcelona. "
            "Welcome the guest, check them in, explain the amenities, "
            "and offer help with luggage. Stay in character throughout."
        ),
    },
    {
        "id": "interview",
        "title": "Job Interview",
        "description": "Practice common interview questions in Spanish",
        "language": "es",
        "category": "roleplay",
        "difficulty": 4,
        "scenario": "interview",
        "xp_reward": 25,
        "prompt_template": (
            "You are an interviewer for a tech company in Madrid. "
            "Ask about their experience, skills, and why they want the job. "
            "Give feedback on their answers. Stay in character throughout."
        ),
    },
    {
        "id": "doctor",
        "title": "Doctor's Visit",
        "description": "Describe symptoms and get a prescription",
        "language": "es",
        "category": "roleplay",
        "difficulty": 3,
        "scenario": "doctor",
        "xp_reward": 20,
        "prompt_template": (
            "You are a doctor at a clinic in Mexico City. "
            "Ask about the patient's symptoms, examine them, "
            "and give a diagnosis with recommendations. "
            "Stay in character throughout."
        ),
    },
]

init_db()


def seed_lessons():
    conn = get_conn()
    existing = conn.execute("SELECT COUNT(*) FROM lessons").fetchone()[0]
    if existing > 0:
        conn.close()
        return {"message": f"{existing} lessons already seeded"}
    for lesson in SEED_LESSONS:
        conn.execute(
            """INSERT INTO lessons (id, title, description, language, category, difficulty, scenario, xp_reward, prompt_template)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (lesson["id"], lesson["title"], lesson["description"],
             lesson["language"], lesson["category"], lesson["difficulty"],
             lesson["scenario"], lesson["xp_reward"], lesson["prompt_template"]),
        )
    conn.commit()
    conn.close()
    return {"message": f"{len(SEED_LESSONS)} lessons seeded"}


def get_lessons(language: str = None, category: str = None) -> list:
    conn = get_conn()
    clauses = []
    params = []
    if language:
        clauses.append("language = ?")
        params.append(language)
    if category:
        clauses.append("category = ?")
        params.append(category)
    where = " AND ".join(clauses) if clauses else "1=1"
    rows = conn.execute(f"SELECT * FROM lessons WHERE {where}", params).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_lesson(lesson_id: str) -> dict | None:
    conn = get_conn()
    row = conn.execute("SELECT * FROM lessons WHERE id = ?", (lesson_id,)).fetchone()
    conn.close()
    return dict(row) if row else None


def start_lesson(user_id: str, lesson_id: str) -> dict | None:
    lesson = get_lesson(lesson_id)
    if not lesson:
        return None
    return ActiveLesson(
        lesson_id=lesson["id"],
        title=lesson["title"],
        description=lesson["description"],
        scenario=lesson["scenario"],
        system_prompt=lesson["prompt_template"],
        xp_reward=lesson["xp_reward"],
    ).model_dump()


def complete_lesson(user_id: str, lesson_id: str, score: int = 0) -> dict:
    from providers.gamification import get_profile
    get_profile(user_id)
    conn = get_conn()
    existing = conn.execute(
        "SELECT * FROM lesson_progress WHERE user_id = ? AND lesson_id = ?",
        (user_id, lesson_id),
    ).fetchone()
    if existing and existing["completed"]:
        conn.close()
        return {"message": "already completed", "xp_earned": 0}
    lesson = get_lesson(lesson_id)
    xp_base = lesson["xp_reward"] if lesson else 10
    xp_bonus = 5 if score > 80 else 0
    if existing:
        conn.execute(
            "UPDATE lesson_progress SET completed = 1, score = ?, completed_at = ?, attempts = attempts + 1 WHERE id = ?",
            (score, datetime.now(timezone.utc).isoformat(), existing["id"]),
        )
    else:
        conn.execute(
            """INSERT INTO lesson_progress (user_id, lesson_id, completed, score, completed_at, attempts)
               VALUES (?, ?, 1, ?, ?, 1)""",
            (user_id, lesson_id, score, datetime.now(timezone.utc).isoformat()),
        )
    conn.commit()
    conn.close()
    return {"xp_earned": xp_base + xp_bonus}


def get_progress(user_id: str) -> dict:
    conn = get_conn()
    rows = conn.execute(
        "SELECT * FROM lesson_progress WHERE user_id = ?", (user_id,)
    ).fetchall()
    conn.close()
    return {r["lesson_id"]: {
        "completed": bool(r["completed"]),
        "score": r["score"],
        "completed_at": r["completed_at"],
        "attempts": r["attempts"],
    } for r in rows}
