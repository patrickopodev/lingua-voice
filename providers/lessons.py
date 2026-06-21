import json
from pathlib import Path
from datetime import datetime

LESSONS_FILE = Path("data") / "lessons.json"
PROGRESS_FILE = Path("data") / "lesson_progress.json"

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

def _load_json(path: Path) -> dict:
    if path.exists():
        return json.loads(path.read_text())
    return {}

def _save_json(path: Path, data: dict):
    path.write_text(json.dumps(data, indent=2))

def seed_lessons():
    Path("data").mkdir(exist_ok=True)
    lessons = _load_json(LESSONS_FILE)
    if lessons:
        return {"message": f"{len(lessons)} lessons already seeded"}
    _save_json(LESSONS_FILE, {l["id"]: l for l in SEED_LESSONS})
    return {"message": f"{len(SEED_LESSONS)} lessons seeded"}

def get_lessons(language: str = None, category: str = None) -> list:
    lessons = _load_json(LESSONS_FILE)
    items = list(lessons.values())
    if language:
        items = [l for l in items if l["language"] == language]
    if category:
        items = [l for l in items if l["category"] == category]
    return items

def get_lesson(lesson_id: str) -> dict | None:
    lessons = _load_json(LESSONS_FILE)
    return lessons.get(lesson_id)

def start_lesson(user_id: str, lesson_id: str) -> dict | None:
    lesson = get_lesson(lesson_id)
    if not lesson:
        return None
    return {
        "lesson_id": lesson["id"],
        "title": lesson["title"],
        "description": lesson["description"],
        "scenario": lesson["scenario"],
        "system_prompt": lesson["prompt_template"],
        "xp_reward": lesson["xp_reward"],
    }

def complete_lesson(user_id: str, lesson_id: str, score: int = 0) -> dict:
    Path("data").mkdir(exist_ok=True)
    progress = _load_json(PROGRESS_FILE)
    if user_id not in progress:
        progress[user_id] = {}
    prev = progress[user_id].get(lesson_id, {})
    if prev.get("completed"):
        return {"message": "already completed", "xp_earned": 0}
    lesson = get_lesson(lesson_id)
    xp_base = lesson["xp_reward"] if lesson else 10
    xp_bonus = 5 if score > 80 else 0
    progress[user_id][lesson_id] = {
        "completed": True,
        "score": score,
        "completed_at": datetime.utcnow().isoformat(),
        "attempts": prev.get("attempts", 0) + 1,
    }
    _save_json(PROGRESS_FILE, progress)
    return {"xp_earned": xp_base + xp_bonus}

def get_progress(user_id: str) -> dict:
    progress = _load_json(PROGRESS_FILE)
    return progress.get(user_id, {})
