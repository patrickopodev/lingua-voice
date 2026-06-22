import pytest
from fastapi.testclient import TestClient

from app import app

client = TestClient(app)


class TestHealth:
    def test_health_endpoint(self):
        resp = client.get("/health")
        assert resp.status_code == 200
        assert resp.json() == {"status": "ok"}

    def test_languages_endpoint(self):
        resp = client.get("/languages")
        assert resp.status_code == 200
        data = resp.json()
        assert "languages" in data
        langs = {l["code"] for l in data["languages"]}
        assert "es" in langs
        assert "fr" in langs


class TestProfile:
    def test_get_profile_creates_new(self, sample_user_id):
        resp = client.post("/profile", json={"user_id": sample_user_id, "text": ""})
        assert resp.status_code == 200
        data = resp.json()
        assert data["user_id"] == sample_user_id
        assert data["total_xp"] == 0
        assert data["level"] == 1

    def test_get_profile_existing(self, sample_user_id):
        client.post("/profile", json={"user_id": sample_user_id, "text": ""})
        resp = client.post("/profile", json={"user_id": sample_user_id, "text": ""})
        assert resp.status_code == 200
        assert resp.json()["total_xp"] == 0


class TestStats:
    def test_stats(self, sample_user_id):
        client.post("/profile", json={"user_id": sample_user_id, "text": ""})
        resp = client.get(f"/stats/{sample_user_id}")
        assert resp.status_code == 200
        data = resp.json()
        assert data["vocabulary_count"] == 0
        assert data["conversations_count"] == 0


class TestVocabulary:
    def test_add_vocab(self, sample_user_id):
        resp = client.post(
            "/vocabulary",
            data={"user_id": sample_user_id, "word": "hola", "translation": "hello", "language": "es"},
        )
        assert resp.status_code == 200
        assert resp.json()["mastery_level"] == 1

    def test_get_vocabulary(self, sample_user_id):
        client.post(
            "/vocabulary",
            data={"user_id": sample_user_id, "word": "hola", "translation": "hello", "language": "es"},
        )
        resp = client.get(f"/vocabulary/{sample_user_id}")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data["words"]) == 1
        assert data["words"][0]["word"] == "hola"

    def test_add_vocab_increases_mastery(self, sample_user_id):
        client.post(
            "/vocabulary",
            data={"user_id": sample_user_id, "word": "hola", "translation": "hello", "language": "es"},
        )
        resp = client.post(
            "/vocabulary",
            data={"user_id": sample_user_id, "word": "hola", "translation": "hello", "language": "es"},
        )
        assert resp.json()["mastery_level"] == 2


class TestLessons:
    def test_seed_lessons(self, seeded_lessons):
        assert seeded_lessons["message"].startswith("6")

    def test_get_lessons(self, seeded_lessons):
        resp = client.get("/lessons")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data["lessons"]) == 6

    def test_get_lessons_filter_language(self, seeded_lessons):
        resp = client.get("/lessons?language=es")
        assert resp.status_code == 200
        assert len(resp.json()["lessons"]) == 6

    def test_get_lessons_empty_language(self, seeded_lessons):
        resp = client.get("/lessons?language=fr")
        assert resp.status_code == 200
        assert len(resp.json()["lessons"]) == 0

    def test_get_lesson_detail(self, seeded_lessons):
        resp = client.get("/lessons/restaurant")
        assert resp.status_code == 200
        assert resp.json()["title"] == "Restaurant Role-Play"

    def test_get_lesson_detail_not_found(self, seeded_lessons):
        resp = client.get("/lessons/nonexistent")
        assert resp.status_code == 404

    def test_start_lesson(self, seeded_lessons, sample_user_id):
        resp = client.post(
            "/lessons/start",
            data={"user_id": sample_user_id, "lesson_id": "restaurant"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["lesson_id"] == "restaurant"
        assert data["xp_reward"] == 15

    def test_start_lesson_not_found(self, seeded_lessons, sample_user_id):
        resp = client.post(
            "/lessons/start",
            data={"user_id": sample_user_id, "lesson_id": "nonexistent"},
        )
        assert resp.status_code == 404

    def test_complete_lesson(self, seeded_lessons, sample_user_id):
        resp = client.post(
            "/lessons/complete",
            data={"user_id": sample_user_id, "lesson_id": "restaurant", "score": 90},
        )
        assert resp.status_code == 200
        assert resp.json()["xp_earned"] > 0

    def test_complete_lesson_twice(self, seeded_lessons, sample_user_id):
        client.post(
            "/lessons/complete",
            data={"user_id": sample_user_id, "lesson_id": "restaurant", "score": 90},
        )
        resp = client.post(
            "/lessons/complete",
            data={"user_id": sample_user_id, "lesson_id": "restaurant", "score": 50},
        )
        assert resp.json()["xp_earned"] == 0
        assert resp.json()["message"] == "already completed"

    def test_get_progress(self, seeded_lessons, sample_user_id):
        client.post(
            "/lessons/complete",
            data={"user_id": sample_user_id, "lesson_id": "restaurant", "score": 85},
        )
        resp = client.get(f"/progress/{sample_user_id}")
        assert resp.status_code == 200
        data = resp.json()
        assert "restaurant" in data
        assert data["restaurant"]["completed"] is True


class TestHistory:
    def test_delete_user(self, sample_user_id):
        client.post("/profile", json={"user_id": sample_user_id, "text": ""})
        resp = client.delete(f"/user/{sample_user_id}")
        assert resp.status_code == 200
        assert resp.json()["message"] == "user data deleted"
