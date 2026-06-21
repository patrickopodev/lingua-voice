import hashlib
import os

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
CACHE_TTL = int(os.getenv("AUDIO_CACHE_TTL", "86400"))


def _audio_key(text: str, language: str) -> str:
    fingerprint = hashlib.sha256(f"{language}:{text}".encode()).hexdigest()[:16]
    return f"tts:{fingerprint}"


async def get_cached_audio(text: str, language: str) -> bytes | None:
    try:
        import redis.asyncio as aioredis
        r = aioredis.from_url(REDIS_URL, socket_connect_timeout=1)
        data = await r.get(_audio_key(text, language))
        await r.aclose()
        return data if data is None else data
    except Exception:
        return None


async def set_cached_audio(text: str, language: str, audio: bytes) -> None:
    try:
        import redis.asyncio as aioredis
        r = aioredis.from_url(REDIS_URL, socket_connect_timeout=1)
        await r.setex(_audio_key(text, language), CACHE_TTL, audio)
        await r.aclose()
    except Exception:
        pass
