import json
from pathlib import Path
from datetime import date, datetime

DATA_DIR = Path("data")
DATA_DIR.mkdir(exist_ok=True)
PROFILES_FILE = DATA_DIR / "profiles.json"
VOCAB_FILE = DATA_DIR / "vocabulary.json"
HISTORY_FILE = DATA_DIR / "conversations.json"

def _load_json(path: Path) -> dict:
    if path.exists():
        return json.loads(path.read_text())
    return {}

def _save_json(path: Path, data: dict):
    path.write_text(json.dumps(data, indent=2))

def get_profile(user_id: str) -> dict:
    profiles = _load_json(PROFILES_FILE)
    if user_id not in profiles:
        profiles[user_id] = {
            "username": f"user_{user_id[:8]}",
            "total_xp": 0,
            "level": 1,
            "streak_days": 0,
            "last_active": str(date.today()),
            "target_language": "es",
            "created_at": datetime.utcnow().isoformat(),
        }
        _save_json(PROFILES_FILE, profiles)
    return profiles[user_id]

def update_profile(user_id: str, updates: dict):
    profiles = _load_json(PROFILES_FILE)
    if user_id not in profiles:
        profiles[user_id] = get_profile(user_id)
    profiles[user_id].update(updates)
    _save_json(PROFILES_FILE, profiles)

def add_xp(user_id: str, xp: int) -> dict:
    profile = get_profile(user_id)
    old_xp = profile["total_xp"]
    new_xp = old_xp + xp
    new_level = (new_xp // 50) + 1
    old_level = profile["level"]

    today = date.today()
    last_active = profile.get("last_active", "")
    streak = profile.get("streak_days", 0)
    if last_active:
        try:
            last_date = date.fromisoformat(last_active)
            diff = (today - last_date).days
            if diff == 1:
                streak += 1
            elif diff > 1:
                streak = 0
        except ValueError:
            streak = 0

    update_profile(user_id, {
        "total_xp": new_xp,
        "level": new_level,
        "streak_days": streak,
        "last_active": str(today),
    })

    return {
        "xp_earned": xp,
        "total_xp": new_xp,
        "level": new_level,
        "leveled_up": new_level > old_level,
        "streak_days": streak,
    }

def get_stats(user_id: str) -> dict:
    profile = get_profile(user_id)
    vocab = _load_json(VOCAB_FILE)
    user_vocab = [v for v in vocab.get(user_id, [])]
    history = _load_json(HISTORY_FILE)
    user_history = [h for h in history.get(user_id, [])]
    return {
        "username": profile["username"],
        "total_xp": profile["total_xp"],
        "level": profile["level"],
        "streak_days": profile["streak_days"],
        "vocabulary_count": len(user_vocab),
        "conversations_count": len(user_history),
        "target_language": profile.get("target_language", "es"),
    }

def add_vocabulary(user_id: str, word: str, translation: str, language: str, context: str = None) -> dict:
    vocab = _load_json(VOCAB_FILE)
    if user_id not in vocab:
        vocab[user_id] = []
    existing = next((v for v in vocab[user_id] if v["word"] == word), None)
    if existing:
        existing["mastery_level"] = min(existing.get("mastery_level", 0) + 1, 5)
        existing["last_reviewed"] = str(date.today())
        existing["context"] = context or existing.get("context")
    else:
        vocab[user_id].append({
            "word": word,
            "translation": translation,
            "language": language,
            "context": context,
            "mastery_level": 1,
            "last_reviewed": str(date.today()),
            "added_at": datetime.utcnow().isoformat(),
        })
    _save_json(VOCAB_FILE, vocab)
    return {"word": word, "mastery_level": existing["mastery_level"] if existing else 1}

def get_vocabulary(user_id: str, language: str = None) -> list:
    vocab = _load_json(VOCAB_FILE)
    items = vocab.get(user_id, [])
    if language:
        items = [v for v in items if v.get("language") == language]
    return sorted(items, key=lambda v: v.get("last_reviewed", ""), reverse=True)

def save_conversation(user_id: str, data: dict):
    history = _load_json(HISTORY_FILE)
    if user_id not in history:
        history[user_id] = []
    history[user_id].append({
        **data,
        "timestamp": datetime.utcnow().isoformat(),
    })
    if len(history[user_id]) > 500:
        history[user_id] = history[user_id][-500:]
    _save_json(HISTORY_FILE, history)

def get_conversation_history(user_id: str, limit: int = 50) -> list:
    history = _load_json(HISTORY_FILE)
    items = history.get(user_id, [])
    return items[-limit:]

def delete_user(user_id: str):
    profiles = _load_json(PROFILES_FILE)
    profiles.pop(user_id, None)
    _save_json(PROFILES_FILE, profiles)
    vocab = _load_json(VOCAB_FILE)
    vocab.pop(user_id, None)
    _save_json(VOCAB_FILE, vocab)
    history = _load_json(HISTORY_FILE)
    history.pop(user_id, None)
    _save_json(HISTORY_FILE, history)
