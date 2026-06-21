from abc import ABC, abstractmethod

class STTProvider(ABC):
    @abstractmethod
    async def transcribe(self, audio_bytes: bytes, language: str) -> str:
        ...

class GroqSTT(STTProvider):
    def __init__(self, api_key: str):
        self.api_key = api_key

    async def transcribe(self, audio_bytes: bytes, language: str) -> str:
        from groq import AsyncGroq
        client = AsyncGroq(api_key=self.api_key)
        transcription = await client.audio.transcriptions.create(
            file=("audio.webm", audio_bytes, "audio/webm"),
            model="whisper-large-v3",
            language=language,
            response_format="json",
        )
        return transcription.text

class SelfHostedSTT(STTProvider):
    def __init__(self, endpoint: str):
        self.endpoint = endpoint.rstrip("/")

    async def transcribe(self, audio_bytes: bytes, language: str) -> str:
        import httpx
        lang_map = {
            "spanish": "es", "french": "fr", "mandarin": "zh", "japanese": "ja",
            "german": "de", "portuguese": "pt", "korean": "ko", "arabic": "ar",
            "hindi": "hi", "italian": "it", "russian": "ru", "hausa": "ha",
        }
        short_lang = lang_map.get(language.lower(), language[:2])
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(
                f"{self.endpoint}/asr",
                files={"audio_file": ("audio.webm", audio_bytes, "audio/webm")},
                data={
                    "language": short_lang,
                    "response_format": "json",
                    "task": "transcribe",
                },
            )
            resp.raise_for_status()
            return resp.json().get("text", "")
