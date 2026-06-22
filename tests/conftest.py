import gc
from pathlib import Path

import pytest


@pytest.fixture(autouse=True)
def _patch_db_path(monkeypatch, tmp_path):
    test_db = tmp_path / "test_linguavoice.db"
    monkeypatch.setattr("providers.database.DB_PATH", test_db)
    from providers.database import init_db
    init_db()
    yield
    gc.collect()


@pytest.fixture
def sample_user_id():
    return "test-user-123"


@pytest.fixture
def seeded_lessons():
    from providers.lessons import seed_lessons
    return seed_lessons()
