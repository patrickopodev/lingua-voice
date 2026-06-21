from abc import ABC, abstractmethod

class TTSProvider(ABC):
    @abstractmethod
    async def speak(self, text: str, language: str) -> bytes:
        ...

class EdgeTTS(TTSProvider):
    async def speak(self, text: str, language: str) -> bytes:
        import edge_tts
        voice_map = {
            "spanish": "es-ES-AlvaroNeural", "french": "fr-FR-DeniseNeural",
            "mandarin": "zh-CN-XiaoxiaoNeural", "japanese": "ja-JP-NanamiNeural",
            "german": "de-DE-KatjaNeural", "portuguese": "pt-BR-FranciscaNeural",
            "korean": "ko-KR-SunHiNeural", "arabic": "ar-SA-ZariyahNeural",
            "hindi": "hi-IN-SwaraNeural", "italian": "it-IT-ElsaNeural",
            "russian": "ru-RU-SvetlanaNeural", "hausa": "en-NG-EzinneNeural",
        }
        voice = voice_map.get(language.lower(), "en-US-JennyNeural")
        tts = edge_tts.Communicate(text, voice)
        audio = b""
        async for chunk in tts.stream():
            if chunk["type"] == "audio":
                audio += chunk["data"]
        return audio

class GoogleTTS(TTSProvider):
    lang_map = {
        "english": "en", "spanish": "es", "french": "fr", "german": "de",
        "italian": "it", "portuguese": "pt", "russian": "ru",
        "japanese": "ja", "korean": "ko", "mandarin": "zh-cn",
        "arabic": "ar", "hindi": "hi", "hausa": "en",
    }

    async def speak(self, text: str, language: str) -> bytes:
        from gtts import gTTS
        import io
        lang = self.lang_map.get(language.lower(), "en")
        tts = gTTS(text=text, lang=lang, slow=False)
        buf = io.BytesIO()
        tts.write_to_fp(buf)
        buf.seek(0)
        return buf.read()

class SelfHostedTTS(TTSProvider):
    def __init__(self, endpoint: str):
        self.endpoint = endpoint.rstrip("/")

    async def speak(self, text: str, language: str) -> bytes:
        import httpx
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(
                f"{self.endpoint}/synthesize",
                json={
                    "text": text,
                    "language": language[:2],
                    "speaker_id": "default",
                    "sample_rate": 24000,
                },
            )
            resp.raise_for_status()
            return resp.content
