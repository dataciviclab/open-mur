"""Smoke test — verifica che tutti i file della dashboard siano sintatticamente validi."""

from __future__ import annotations

import py_compile
from pathlib import Path

import pytest

pytestmark = pytest.mark.smoke

DASHBOARD_DIR = Path(__file__).resolve().parent.parent
PAGES_DIR = DASHBOARD_DIR / "pages"


def _all_py_files() -> list[Path]:
    files = [DASHBOARD_DIR / "app.py", DASHBOARD_DIR / "sources.py"]
    files.extend(sorted(PAGES_DIR.glob("*.py")))
    return files


@pytest.mark.smoke
@pytest.mark.parametrize("py_file", _all_py_files(), ids=lambda p: p.name)
def test_py_compile(py_file: Path):
    """Ogni file .py deve essere sintatticamente valido."""
    py_compile.compile(str(py_file), doraise=True)
