import sqlite3
import json
from pathlib import Path
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, Field

DB_PATH = Path("data") / "linguavoice.db"

def get_conn() -> sqlite3.Connection:
    DB_PATH.parent.mkdir(exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")
    return conn

def init_db():
    conn = get_conn()
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            user_id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            total_xp INTEGER NOT NULL DEFAULT 0,
            level INTEGER NOT NULL DEFAULT 1,
            streak_days INTEGER NOT NULL DEFAULT 0,
            last_active TEXT NOT NULL,
            target_language TEXT NOT NULL DEFAULT 'es',
            created_at TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS vocabulary (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL REFERENCES users(user_id),
            word TEXT NOT NULL,
            translation TEXT NOT NULL,
            language TEXT NOT NULL,
            context TEXT,
            mastery_level INTEGER NOT NULL DEFAULT 1,
            last_reviewed TEXT NOT NULL,
            added_at TEXT NOT NULL,
            UNIQUE(user_id, word)
        );

        CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL REFERENCES users(user_id),
            data TEXT NOT NULL,
            timestamp TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS lessons (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            language TEXT NOT NULL DEFAULT 'es',
            category TEXT NOT NULL DEFAULT 'roleplay',
            difficulty INTEGER NOT NULL DEFAULT 1,
            scenario TEXT,
            xp_reward INTEGER NOT NULL DEFAULT 10,
            prompt_template TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS lesson_progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL REFERENCES users(user_id),
            lesson_id TEXT NOT NULL REFERENCES lessons(id),
            completed INTEGER NOT NULL DEFAULT 0,
            score INTEGER NOT NULL DEFAULT 0,
            completed_at TEXT,
            attempts INTEGER NOT NULL DEFAULT 0,
            UNIQUE(user_id, lesson_id)
        );

        CREATE INDEX IF NOT EXISTS idx_vocab_user ON vocabulary(user_id);
        CREATE INDEX IF NOT EXISTS idx_conv_user ON conversations(user_id);
        CREATE INDEX IF NOT EXISTS idx_progress_user ON lesson_progress(user_id);
    """)
    conn.commit()
    conn.close()

# Pydantic models
class UserProfile(BaseModel):
    user_id: str
    username: str
    total_xp: int = 0
    level: int = 1
    streak_days: int = 0
    last_active: str = ""
    target_language: str = "es"
    created_at: str = ""

class VocabularyWord(BaseModel):
    word: str
    translation: str
    language: str
    context: Optional[str] = None
    mastery_level: int = 1
    last_reviewed: str = ""
    added_at: str = ""

class Lesson(BaseModel):
    id: str
    title: str
    description: str
    language: str = "es"
    category: str = "roleplay"
    difficulty: int = 1
    scenario: Optional[str] = None
    xp_reward: int = 10
    prompt_template: str

class ConversationEntry(BaseModel):
    data: dict
    timestamp: str = ""

class Stats(BaseModel):
    username: str
    total_xp: int
    level: int
    streak_days: int
    vocabulary_count: int
    conversations_count: int
    target_language: str

class XPResult(BaseModel):
    xp_earned: int
    total_xp: int
    level: int
    leveled_up: bool
    streak_days: int

class ActiveLesson(BaseModel):
    lesson_id: str
    title: str
    description: str
    scenario: Optional[str] = None
    system_prompt: str = ""
    xp_reward: int = 0

class CompletionResult(BaseModel):
    message: str = "completed"
    xp_earned: int = 0
