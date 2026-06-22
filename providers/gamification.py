import json
from datetime import date, datetime, timezone

from providers.database import get_conn, init_db, UserProfile, XPResult, Stats, VocabularyWord

init_db()


def get_profile(user_id: str) -> dict:
    conn = get_conn()
    row = conn.execute(
        "SELECT * FROM users WHERE user_id = ?", (user_id,)
    ).fetchone()
    if row:
        conn.close()
        return dict(row)
    profile = UserProfile(
        user_id=user_id,
        username=f"user_{user_id[:8]}",
        last_active=str(date.today()),
        created_at=datetime.now(timezone.utc).isoformat(),
    )
    conn.execute(
        """INSERT INTO users (user_id, username, total_xp, level, streak_days, last_active, target_language, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
        (profile.user_id, profile.username, profile.total_xp, profile.level,
         profile.streak_days, profile.last_active, profile.target_language, profile.created_at),
    )
    conn.commit()
    conn.close()
    return profile.model_dump()


def update_profile(user_id: str, updates: dict):
    conn = get_conn()
    existing = conn.execute("SELECT * FROM users WHERE user_id = ?", (user_id,)).fetchone()
    if not existing:
        get_profile(user_id)
    allowed = {"username", "total_xp", "level", "streak_days", "last_active", "target_language"}
    set_clause = ", ".join(f"{k} = ?" for k in updates if k in allowed)
    vals = [updates[k] for k in updates if k in allowed]
    if set_clause:
        conn.execute(f"UPDATE users SET {set_clause} WHERE user_id = ?", (*vals, user_id))
        conn.commit()
    conn.close()


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
    return XPResult(
        xp_earned=xp,
        total_xp=new_xp,
        level=new_level,
        leveled_up=new_level > old_level,
        streak_days=streak,
    ).model_dump()


def get_stats(user_id: str) -> dict:
    profile = get_profile(user_id)
    conn = get_conn()
    vocab_count = conn.execute(
        "SELECT COUNT(*) FROM vocabulary WHERE user_id = ?", (user_id,)
    ).fetchone()[0]
    conv_count = conn.execute(
        "SELECT COUNT(*) FROM conversations WHERE user_id = ?", (user_id,)
    ).fetchone()[0]
    conn.close()
    return Stats(
        username=profile["username"],
        total_xp=profile["total_xp"],
        level=profile["level"],
        streak_days=profile["streak_days"],
        vocabulary_count=vocab_count,
        conversations_count=conv_count,
        target_language=profile.get("target_language", "es"),
    ).model_dump()


def add_vocabulary(user_id: str, word: str, translation: str, language: str, context: str = None) -> dict:
    get_profile(user_id)
    conn = get_conn()
    existing = conn.execute(
        "SELECT * FROM vocabulary WHERE user_id = ? AND word = ?", (user_id, word)
    ).fetchone()
    if existing:
        new_level = min(existing["mastery_level"] + 1, 5)
        conn.execute(
            "UPDATE vocabulary SET mastery_level = ?, last_reviewed = ?, context = COALESCE(?, context) WHERE id = ?",
            (new_level, str(date.today()), context, existing["id"]),
        )
        conn.commit()
        conn.close()
        return {"word": word, "mastery_level": new_level}
    conn.execute(
        """INSERT INTO vocabulary (user_id, word, translation, language, context, mastery_level, last_reviewed, added_at)
           VALUES (?, ?, ?, ?, ?, 1, ?, ?)""",
        (user_id, word, translation, language, context, str(date.today()), datetime.now(timezone.utc).isoformat()),
    )
    conn.commit()
    conn.close()
    return {"word": word, "mastery_level": 1}


def get_vocabulary(user_id: str, language: str = None) -> list:
    conn = get_conn()
    if language:
        rows = conn.execute(
            "SELECT * FROM vocabulary WHERE user_id = ? AND language = ? ORDER BY last_reviewed DESC",
            (user_id, language),
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT * FROM vocabulary WHERE user_id = ? ORDER BY last_reviewed DESC", (user_id,)
        ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def save_conversation(user_id: str, data: dict):
    get_profile(user_id)
    conn = get_conn()
    conn.execute(
        "INSERT INTO conversations (user_id, data, timestamp) VALUES (?, ?, ?)",
        (user_id, json.dumps(data), datetime.now(timezone.utc).isoformat()),
    )
    conn.execute(
        """DELETE FROM conversations WHERE id IN (
               SELECT id FROM conversations WHERE user_id = ? ORDER BY timestamp ASC
               LIMIT MAX(0, (SELECT COUNT(*) FROM conversations WHERE user_id = ?) - 500)
           )""",
        (user_id, user_id),
    )
    conn.commit()
    conn.close()


def get_conversation_history(user_id: str, limit: int = 50) -> list:
    conn = get_conn()
    rows = conn.execute(
        "SELECT * FROM conversations WHERE user_id = ? ORDER BY timestamp DESC LIMIT ?",
        (user_id, limit),
    ).fetchall()
    conn.close()
    result = []
    for r in reversed(rows):
        d = dict(r)
        try:
            data = json.loads(d["data"])
        except (json.JSONDecodeError, TypeError):
            data = d["data"]
        result.append({**data, "timestamp": d["timestamp"]})
    return result


def delete_user(user_id: str):
    conn = get_conn()
    conn.execute("DELETE FROM conversations WHERE user_id = ?", (user_id,))
    conn.execute("DELETE FROM vocabulary WHERE user_id = ?", (user_id,))
    conn.execute("DELETE FROM lesson_progress WHERE user_id = ?", (user_id,))
    conn.execute("DELETE FROM users WHERE user_id = ?", (user_id,))
    conn.commit()
    conn.close()
