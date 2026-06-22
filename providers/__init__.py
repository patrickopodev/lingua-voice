import os
from .stt import STTProvider, GroqSTT, SelfHostedSTT
from .llm import LLMProvider, GroqLLM, SelfHostedLLM
from .tts import TTSProvider, EdgeTTS, GoogleTTS, SelfHostedTTS
from .cache import get_cached_audio, set_cached_audio


def validate_providers():
    kind_llm = os.getenv("LLM_PROVIDER", "groq")
    kind_stt = os.getenv("STT_PROVIDER", "groq")
    groq_key = os.getenv("GROQ_API_KEY", "")
    if (kind_llm == "groq" or kind_stt == "groq") and not groq_key:
        raise RuntimeError(
            "GROQ_API_KEY is required when LLM_PROVIDER or STT_PROVIDER is 'groq'. "
            "Set it in your .env file or Render dashboard."
        )

class CachedTTS(TTSProvider):
    def __init__(self, inner: TTSProvider):
        self._inner = inner

    async def speak(self, text: str, language: str) -> bytes:
        cached = await get_cached_audio(text, language)
        if cached is not None:
            return cached
        audio = await self._inner.speak(text, language)
        await set_cached_audio(text, language, audio)
        return audio


def get_stt() -> STTProvider:
    kind = os.getenv("STT_PROVIDER", "groq")
    if kind == "groq":
        return GroqSTT(api_key=os.getenv("GROQ_API_KEY", ""))
    elif kind == "self_hosted":
        return SelfHostedSTT(endpoint=os.getenv("STT_ENDPOINT", "http://whisper:9000"))
    raise ValueError(f"Unknown STT provider: {kind}")


def get_llm() -> LLMProvider:
    kind = os.getenv("LLM_PROVIDER", "groq")
    if kind == "groq":
        return GroqLLM(
            api_key=os.getenv("GROQ_API_KEY", ""),
            model=os.getenv("LLM_MODEL", "llama-3.3-70b-versatile"),
        )
    elif kind == "self_hosted":
        return SelfHostedLLM(
            endpoint=os.getenv("LLM_ENDPOINT", "http://ollama:11434"),
            model=os.getenv("LLM_MODEL", "qwen:32b-chat"),
        )
    raise ValueError(f"Unknown LLM provider: {kind}")


def get_tts() -> TTSProvider:
    kind = os.getenv("TTS_PROVIDER", "edge")
    inner: TTSProvider
    if kind == "edge":
        inner = EdgeTTS()
    elif kind == "google":
        inner = GoogleTTS()
    elif kind == "self_hosted":
        inner = SelfHostedTTS(endpoint=os.getenv("TTS_ENDPOINT", "http://supertonic:8000"))
    else:
        raise ValueError(f"Unknown TTS provider: {kind}")
    if os.getenv("REDIS_URL"):
        return CachedTTS(inner)
    return inner
