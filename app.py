from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from providers.fastapi_demo import router

app = FastAPI(title="LinguaVoice API")
app.include_router(router)

AUDIO_CACHE = Path("audio_cache")
AUDIO_CACHE.mkdir(exist_ok=True)
app.mount("/audio", StaticFiles(directory=AUDIO_CACHE), name="audio")

LANGUAGES = {
    "english": "en", "spanish": "es", "french": "fr", "german": "de",
    "italian": "it", "portuguese": "pt", "russian": "ru",
    "japanese": "ja", "korean": "ko", "mandarin": "zh",
    "arabic": "ar", "hindi": "hi", "hausa": "ha",
}

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/languages")
async def languages():
    return {"languages": [{"code": v, "name": k} for k, v in LANGUAGES.items()]}
