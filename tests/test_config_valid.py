"""Validazione configurazioni dataset.yml.

Verifica che ogni dataset.yml nel repo sia strutturalmente valido
e contenga i campi obbligatori secondo lo standard toolkit.
"""

from __future__ import annotations

from pathlib import Path

import pytest
import yaml

ROOT = Path(__file__).resolve().parents[1]
DATASETS_DIR = ROOT / "datasets"
SUPPORT_DIR = ROOT / "support"


def _find_dataset_configs() -> list[tuple[str, Path]]:
    """Trova tutti i dataset.yml nel repo."""
    configs = []
    for base in [DATASETS_DIR, SUPPORT_DIR]:
        if not base.exists():
            continue
        for yml in sorted(base.rglob("dataset.yml")):
            rel = yml.relative_to(ROOT)
            configs.append((str(rel), yml))
    return configs


CONFIGS = _find_dataset_configs()


@pytest.mark.policy
@pytest.mark.parametrize("config_path", [c[1] for c in CONFIGS], ids=[c[0] for c in CONFIGS])
def test_dataset_yaml_valid(config_path: Path):
    """Ogni dataset.yml deve essere YAML valido."""
    data = yaml.safe_load(config_path.read_text())
    assert data is not None, f"{config_path}: YAML vuoto"


@pytest.mark.policy
@pytest.mark.parametrize("config_path", [c[1] for c in CONFIGS], ids=[c[0] for c in CONFIGS])
def test_dataset_has_required_sections(config_path: Path):
    """Ogni dataset.yml deve avere le sezioni obbligatorie."""
    data = yaml.safe_load(config_path.read_text())
    assert "schema_version" in data, f"{config_path}: manca schema_version"
    assert "dataset" in data, f"{config_path}: manca sezione dataset"
    assert "raw" in data or "clean" in data, f"{config_path}: mancano raw e clean"


@pytest.mark.policy
@pytest.mark.parametrize("config_path", [c[1] for c in CONFIGS], ids=[c[0] for c in CONFIGS])
def test_dataset_has_name_and_source(config_path: Path):
    """Ogni dataset deve avere name e source_id."""
    data = yaml.safe_load(config_path.read_text())
    ds = data.get("dataset", {})
    assert "name" in ds, f"{config_path}: manca dataset.name"
    assert "source_id" in ds, f"{config_path}: manca dataset.source_id"


@pytest.mark.policy
@pytest.mark.parametrize("config_path", [c[1] for c in CONFIGS], ids=[c[0] for c in CONFIGS])
def test_clean_has_sql(config_path: Path):
    """Se presente, la sezione clean deve avere sql."""
    data = yaml.safe_load(config_path.read_text())
    clean = data.get("clean")
    if clean is None:
        pytest.skip("nessuna sezione clean")
    assert "sql" in clean, f"{config_path}: clean manca 'sql'"


@pytest.mark.policy
@pytest.mark.parametrize("config_path", [c[1] for c in CONFIGS], ids=[c[0] for c in CONFIGS])
def test_sql_files_exist(config_path: Path):
    """I file SQL referenziati devono esistere."""
    data = yaml.safe_load(config_path.read_text())
    base_dir = config_path.parent

    clean = data.get("clean", {})
    if "sql" in clean:
        sql_path = base_dir / clean["sql"]
        assert sql_path.exists(), f"{config_path}: {clean['sql']} non trovato"

    mart = data.get("mart", {})
    for table in mart.get("tables", []):
        if "sql" in table:
            sql_path = base_dir / table["sql"]
            assert sql_path.exists(), f"{config_path}: {table['sql']} non trovato"
