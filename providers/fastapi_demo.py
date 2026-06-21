import json
import uuid
from datetime import datetime
from pathlib import Path

from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel

from providers import get_stt, get_llm, get_tts
from providers.llm import parse_llm_response
from providers.gamification import (
    add_xp, get_profile, get_stats, add_vocabulary,
    get_vocabulary, save_conversation, get_conversation_history, delete_user,
)
from providers.lessons import seed_lessons, get_lessons, get_lesson, start_lesson, complete_lesson, get_progress

router = APIRouter()
stt = get_stt()
llm = get_llm()
tts = get_tts()

AUDIO_CACHE = Path("audio_cache")
AUDIO_CACHE.mkdir(exist_ok=True)

class ChatRequest(BaseModel):
    text: str
    language: str = "spanish"
    history: list = []
    user_id: str = "default"

class SpeakRequest(BaseModel):
    text: str
    language: str = "spanish"

# ── Transcribe ──────────────────────────────────────────

@router.post("/translate_and_speak")
async def translate_and_speak(
    text: str = Form(...),
    target_language: str = Form("en"),
):
    try:
        translation_prompt = (
            f"Translate the following text to {target_language}. "
            f"Return only the translation, no other text.\n\n{text}"
        )
        translated_text = await llm.generate(
            translation_prompt,
            target_language,
            [{"role": "system", "content": "You are a translator. Return only the translation."}],
        )
        translated_text = translated_text.strip().strip('"\'')
        audio_data = await tts.speak(translated_text, target_language)
        filename = f"{uuid.uuid4().hex}.mp3"
        filepath = AUDIO_CACHE / filename
        filepath.write_bytes(audio_data)
        return {
            "translated_text": translated_text,
            "audio_url": f"/audio/{filename}",
            "target_language": target_language,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/transcribe")
async def transcribe(audio: UploadFile = File(...), language: str = Form("spanish")):
    text = await stt.transcribe(await audio.read(), language)
    return {"text": text}

# ── Chat ────────────────────────────────────────────────

@router.post("/chat")
async def chat(req: ChatRequest):
    raw_response = await llm.generate(req.text, req.language, req.history)
    parsed = parse_llm_response(raw_response)
    response_text = parsed["response_text"]
    correction = parsed["correction"]

    result = {
        "response": response_text,
        "correction": correction,
    }

    if req.user_id:
        xp_result = add_xp(req.user_id, 5)
        result["xp"] = xp_result

        if correction.get("vocab"):
            for v in correction["vocab"][:5]:
                add_vocabulary(req.user_id, v["word"], v.get("translation", ""), req.language)

        conversation_data = {
            "user_text": req.text,
            "response": response_text,
            "language": req.language,
        }
        save_conversation(req.user_id, conversation_data)

    return result

# ── Speak ───────────────────────────────────────────────

@router.post("/speak")
async def speak(req: SpeakRequest):
    audio = await tts.speak(req.text, req.language)
    return Response(content=audio, media_type="audio/mpeg")

# ── Conversation (enhanced) ────────────────────────────

@router.post("/conversation")
async def conversation(
    audio: UploadFile = File(...),
    language: str = Form("spanish"),
    history: str = Form("[]"),
    user_id: str = Form("default"),
    lesson_id: str = Form(None),
):
    try:
        history_list = json.loads(history)
    except json.JSONDecodeError:
        history_list = []

    text = await stt.transcribe(await audio.read(), language)
    raw_response = await llm.generate(text, language, history_list)
    parsed = parse_llm_response(raw_response)
    response_text = parsed["response_text"]
    correction = parsed["correction"]

    audio_data = await tts.speak(response_text, language)

    filename = f"{uuid.uuid4().hex}.mp3"
    filepath = AUDIO_CACHE / filename
    filepath.write_bytes(audio_data)

    xp_result = add_xp(user_id, 10)

    if correction.get("vocab"):
        for v in correction["vocab"][:5]:
            add_vocabulary(user_id, v["word"], v.get("translation", ""), language)

    conversation_data = {
        "user_text": text,
        "response": response_text,
        "audio_url": f"/audio/{filename}",
        "language": language,
    }
    save_conversation(user_id, conversation_data)

    result = {
        "user_text": text,
        "response": response_text,
        "audio_url": f"/audio/{filename}",
        "language": language,
        "timestamp": datetime.utcnow().isoformat(),
        "correction": correction,
        "xp": xp_result,
    }

    if lesson_id:
        lesson_result = complete_lesson(user_id, lesson_id)
        xp_from_lesson = lesson_result.get("xp_earned", 0)
        if xp_from_lesson > 0:
            xp_result = add_xp(user_id, xp_from_lesson)
            result["xp"] = xp_result
            result["lesson_completed"] = True

    return result

# ── User Profile & Stats ───────────────────────────────

@router.get("/stats/{user_id}")
async def stats(user_id: str):
    return get_stats(user_id)

@router.post("/profile")
async def profile(req: ChatRequest):
    return get_profile(req.user_id)

# ── Vocabulary ──────────────────────────────────────────

@router.get("/vocabulary/{user_id}")
async def vocabulary(user_id: str, language: str = None):
    return {"words": get_vocabulary(user_id, language)}

@router.post("/vocabulary")
async def add_vocab(user_id: str = Form(...), word: str = Form(...), translation: str = Form(...), language: str = Form("es"), context: str = Form(None)):
    return add_vocabulary(user_id, word, translation, language, context)

# ── Conversation History ────────────────────────────────

@router.get("/history/{user_id}")
async def history(user_id: str, limit: int = 50):
    return {"conversations": get_conversation_history(user_id, limit)}

@router.delete("/user/{user_id}")
async def delete_user_data(user_id: str):
    delete_user(user_id)
    return {"message": "user data deleted"}

# ── Lessons ─────────────────────────────────────────────

@router.post("/lessons/seed")
async def seed():
    return seed_lessons()

@router.get("/lessons")
async def lessons(language: str = None, category: str = None):
    return {"lessons": get_lessons(language, category)}

@router.get("/lessons/{lesson_id}")
async def lesson_detail(lesson_id: str):
    lesson = get_lesson(lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="lesson not found")
    return lesson

@router.post("/lessons/start")
async def start(user_id: str = Form(...), lesson_id: str = Form(...)):
    lesson = start_lesson(user_id, lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="lesson not found")
    return lesson

@router.post("/lessons/complete")
async def complete(user_id: str = Form(...), lesson_id: str = Form(...), score: int = Form(0)):
    return complete_lesson(user_id, lesson_id, score)

@router.get("/progress/{user_id}")
async def progress(user_id: str):
    return get_progress(user_id)
