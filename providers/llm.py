import json
import re
from abc import ABC, abstractmethod

CORRECTION_PROMPT = (
    "Before your response, output a JSON block with grammar analysis:\n"
    '  ```json\n'
    '  {{"corrected": "<corrected sentence or empty if no errors>", "has_errors": true/false, "corrections": [{{"error": "<what was wrong>", "fix": "<how to fix it>"}}], "vocab": [{{"word": "<word>", "translation": "<english meaning>"}}]}}\n'
    '  ```\n'
    "Then respond naturally to their message in {language}.\n"
    "If the user writes in English, set corrected to empty and has_errors to false, then respond normally in {language}.\n"
    "Keep conversational responses under 3 sentences."
)

class LLMProvider(ABC):
    @abstractmethod
    async def generate(self, prompt: str, language: str, history: list) -> str:
        ...

class GroqLLM(LLMProvider):
    def __init__(self, api_key: str, model: str = "llama-3.3-70b-versatile"):
        self.api_key = api_key
        self.model = model

    async def generate(self, prompt: str, language: str, history: list) -> str:
        from groq import AsyncGroq
        client = AsyncGroq(api_key=self.api_key)
        system_prompt = (
            f"You are a friendly language tutor for {language}. "
            f"When the user writes in {language}, gently correct any grammar mistakes.\n"
            + CORRECTION_PROMPT.format(language=language)
        )
        messages = [
            {"role": "system", "content": system_prompt},
            *history[-10:],
            {"role": "user", "content": prompt},
        ]
        resp = await client.chat.completions.create(model=self.model, messages=messages)
        return resp.choices[0].message.content

class SelfHostedLLM(LLMProvider):
    def __init__(self, endpoint: str, model: str = "qwen:32b-chat"):
        self.endpoint = endpoint.rstrip("/")
        self.model = model

    async def generate(self, prompt: str, language: str, history: list) -> str:
        import httpx
        system_prompt = (
            f"You are a friendly language tutor for {language}. "
            f"When the user writes in {language}, gently correct any grammar mistakes.\n"
            + CORRECTION_PROMPT.format(language=language)
        )
        messages = [{"role": "system", "content": system_prompt}]
        for h in history[-10:]:
            messages.append({"role": h.get("role", "user"), "content": h.get("content", "")})
        messages.append({"role": "user", "content": prompt})
        async with httpx.AsyncClient(timeout=120.0) as client:
            resp = await client.post(
                f"{self.endpoint}/v1/chat/completions",
                json={
                    "model": self.model,
                    "messages": messages,
                    "temperature": 0.7,
                    "max_tokens": 512,
                    "stream": False,
                },
            )
            resp.raise_for_status()
            return resp.json()["choices"][0]["message"]["content"]

def parse_llm_response(text: str) -> dict:
    match = re.search(r'```json\s*(\{.*?\})\s*```', text, re.DOTALL)
    correction = {"corrected": "", "has_errors": False, "corrections": [], "vocab": []}
    response_text = text.strip()
    if match:
        try:
            data = json.loads(match.group(1))
            correction.update(data)
            response_text = text[match.end():].strip()
        except json.JSONDecodeError:
            pass
    if not correction.get("corrections"):
        correction["corrections"] = []
    if not correction.get("vocab"):
        correction["vocab"] = []
    return {
        "correction": correction,
        "response_text": response_text,
    }
