"""Contract test per gli output mart.

Verifica che i parquet prodotti dalla pipeline abbiano lo schema
e le colonne contrattuali definite nei dataset.yml.

Skip-based: i test girano solo se i parquet esistono localmente.
"""

from __future__ import annotations

from pathlib import Path

import duckdb
import pytest

pytestmark = pytest.mark.contract

ROOT = Path(__file__).resolve().parents[1]
MART_BASE = ROOT / "out" / "data" / "mart"


# Mappa slug dataset → (mart name, required_columns)
MART_CONTRACTS = [
    ("mur_laureati", "mart_laureati_efficienza", [
        "anno", "ateneo_cod", "ateneo_nome", "macro_area", "totale", "share_nazionale", "ranking",
    ]),
    ("mur_iscritti", "mart_iscritti_concentrazione", [
        "anno", "ateneo_cod", "ateneo_nome", "macro_area", "totale", "share_nazionale", "ranking",
    ]),
    ("mur_immatricolati", "mart_immatricolati_area", [
        "anno", "classe_cod", "classe_nome", "totale", "donne", "uomini", "pct_donne", "share_totale",
    ]),
    ("mur_contribuzione_universitaria", "mart_contribuzione_trend", [
        "anno", "descrizione_gettito", "totale_euro", "milioni",
    ]),
    ("mur_personale", "mart_personale_distribuzione", [
        "anno", "codice_qualifica", "desc_qualifica", "totale", "pct_donne", "share_totale",
    ]),
    ("mur_personale_ateneo", "mart_personale_per_ateneo", [
        "anno", "cod_ateneo", "grade", "genere", "totale",
    ]),
    ("mur_laureati_voto", "mart_laureati_per_voto", [
        "anno", "classe_voto", "genere", "totale",
    ]),
    ("mur_formazione_post_laurea", "mart_post_laurea_area", [
        "anno_accademico", "macro_area", "livello", "totale",
    ]),
    ("mur_tasso_abbandono", "mart_tasso_abbandono", [
        "anno_accademico", "tasso_m", "tasso_f", "tasso_totale", "gap_genere",
    ]),
    ("mur_offerta_formativa", "mart_offerta_per_ateneo", [
        "anno", "ateneo_cod", "classe", "lingua",
    ]),
]


def _parquet(slug: str, mart: str) -> Path:
    """Risolvi il path del parquet per uno slug dataset."""
    # Cerca l'anno più recente
    mart_dir = MART_BASE / slug
    if not mart_dir.exists():
        return mart_dir / "9999" / f"{mart}.parquet"  # non esisterà → skip
    years = sorted([d.name for d in mart_dir.iterdir() if d.is_dir()], reverse=True)
    if not years:
        return mart_dir / "9999" / f"{mart}.parquet"
    return mart_dir / years[0] / f"{mart}.parquet"


def _skip_if_missing(path: Path) -> Path:
    if not path.exists():
        pytest.skip(f"{path.name} non presente — esegui prima la pipeline")
    return path


@pytest.mark.parametrize(
    "slug,mart_name,required_columns",
    MART_CONTRACTS,
    ids=[f"{c[0]}/{c[1]}" for c in MART_CONTRACTS],
)
def test_mart_has_required_columns(slug: str, mart_name: str, required_columns: list[str]):
    """Il mart deve avere tutte le colonne contrattuali."""
    path = _skip_if_missing(_parquet(slug, mart_name))
    con = duckdb.connect()
    try:
        columns = con.execute(
            "SELECT column_name FROM (DESCRIBE SELECT * FROM read_parquet(?))",
            [str(path)],
        ).fetchall()
        col_names = {r[0] for r in columns}
        missing = set(required_columns) - col_names
        assert not missing, f"{mart_name}: colonne mancanti {missing}"
    finally:
        con.close()


@pytest.mark.parametrize(
    "slug,mart_name,required_columns",
    MART_CONTRACTS,
    ids=[f"{c[0]}/{c[1]}" for c in MART_CONTRACTS],
)
def test_mart_not_empty(slug: str, mart_name: str, required_columns: list[str]):
    """Il mart deve contenere almeno una riga."""
    path = _skip_if_missing(_parquet(slug, mart_name))
    con = duckdb.connect()
    try:
        count = con.execute(
            "SELECT COUNT(*) FROM read_parquet(?)",
            [str(path)],
        ).fetchone()[0]
        assert count > 0, f"{mart_name}: 0 righe"
    finally:
        con.close()
