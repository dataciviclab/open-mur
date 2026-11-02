"""Contract test su anagrafica atenei e serie iscritti.

Coprono tre regole emerse dall'audit 2026-11:
1. ogni provincia MUR è mappata a sigla + codice ISTAT;
2. la serie iscritti ha il gap 2009 noto e non va "riempita" artificialmente;
3. `provincia` è la sede dell'ateneo (costante per ateneo), non la residenza
   dello studente: non è una chiave di join su dati di studenti.

Skip-based: girano solo se i parquet locali esistono (dopo `make run`).
"""

from __future__ import annotations

import re
from pathlib import Path

import duckdb
import pytest

ROOT = Path(__file__).resolve().parents[1]
MART_BASE = ROOT / "out" / "data" / "mart"
CLEAN_BASE = ROOT / "out" / "data" / "clean"


def _latest_parquet(base: Path, slug: str, pattern: str) -> Path | None:
    """Ritorna il parquet più recente per uno slug, o None se assente."""
    slug_dir = base / slug
    if not slug_dir.exists():
        return None
    for year_dir in sorted((d for d in slug_dir.iterdir() if d.is_dir()), reverse=True):
        hits = sorted(year_dir.glob(pattern))
        if hits:
            return hits[0]
    return None


@pytest.mark.contract
def test_anagrafica_province_mappate():
    """Ogni provincia non nulla deve avere sigla e codice ISTAT validi."""
    path = _latest_parquet(MART_BASE, "mur_anagrafica_atenei", "*.parquet")
    if path is None:
        pytest.skip("mart mur_anagrafica_atenei assente — esegui prima la pipeline")

    con = duckdb.connect()
    try:
        unmapped = con.execute(
            """
            SELECT count(*) FROM read_parquet(?)
            WHERE provincia IS NOT NULL
              AND (sigla_provincia IS NULL OR cod_provincia_istat IS NULL)
            """,
            [str(path)],
        ).fetchone()[0]
        assert unmapped == 0, f"{unmapped} atenei con provincia non mappata"

        bad_shape = con.execute(
            """
            SELECT count(*) FROM read_parquet(?)
            WHERE provincia IS NOT NULL
              AND (length(sigla_provincia) <> 2 OR length(cod_provincia_istat) <> 3)
            """,
            [str(path)],
        ).fetchone()[0]
        assert bad_shape == 0, f"{bad_shape} codici provincia con formato inatteso"
    finally:
        con.close()


@pytest.mark.contract
def test_iscritti_gap_2009_noto():
    """La serie iscritti parte dal 2000, è continua tranne il 2009 (gap MUR)."""
    path = _latest_parquet(MART_BASE, "mur_iscritti", "*.parquet")
    if path is None:
        pytest.skip("mart mur_iscritti assente — esegui prima la pipeline")

    con = duckdb.connect()
    try:
        years = [
            r[0]
            for r in con.execute(
                "SELECT DISTINCT anno FROM read_parquet(?) ORDER BY anno", [str(path)]
            ).fetchall()
        ]
    finally:
        con.close()

    assert years, "serie iscritti vuota"
    assert 2009 not in years, "il 2009 non deve essere presente (gap anagrafico MUR)"
    attesi = [y for y in range(min(years), max(years) + 1) if y != 2009]
    assert years == attesi, f"serie non continua: {years}"


@pytest.mark.policy
def test_provincia_e_sede_non_residenza():
    """`provincia` è costante per ateneo: è la sede, non la residenza."""
    path = _latest_parquet(CLEAN_BASE, "mur_iscritti", "*_clean.parquet")
    if path is None:
        pytest.skip("clean mur_iscritti assente — esegui prima la pipeline")

    con = duckdb.connect()
    try:
        variabili = con.execute(
            """
            SELECT count(*) FROM (
                SELECT ateneo_cod FROM read_parquet(?)
                GROUP BY 1 HAVING count(DISTINCT provincia) > 1
            )
            """,
            [str(path)],
        ).fetchone()[0]
        assert variabili == 0, f"{variabili} atenei con più di una provincia"
    finally:
        con.close()


# --- Validazione del lookup scritto in clean.sql -------------------------------
# Il lookup è statico e scritto a mano: questi test controllano la SORGENTE, non
# solo l'output (che copre solo le ~53 province usate dagli atenei).
# Le coppie golden sono verificate su BDAP Anagrafe Enti / ISTAT.

CLEAN_SQL = ROOT / "support" / "anagrafica-atenei" / "sql" / "clean.sql"
_TUPLA_RE = re.compile(r"\('((?:[^']|'')*)',\s*'([A-Z]{2})',\s*'(\d{3})'\)")


def _lookup_pairs() -> list[tuple[str, str, str]]:
    """Estrae (provincia, sigla, codice) dal blocco VALUES di clean.sql."""
    testo = CLEAN_SQL.read_text(encoding="utf-8")
    return [
        (provincia.replace("''", "'"), sigla, codice)
        for provincia, sigla, codice in _TUPLA_RE.findall(testo)
    ]


@pytest.mark.contract
def test_lookup_province_struttura():
    """112 righe (110 province + 2 alias), chiavi univoche e coerenti."""
    pairs = _lookup_pairs()
    assert len(pairs) == 112, f"attese 112 righe, trovate {len(pairs)}"

    province = [p for p, _, _ in pairs]
    assert len(province) == len(set(province)), "province duplicate nel lookup"

    per_sigla: dict[str, str] = {}
    per_codice: dict[str, str] = {}
    for _, sigla, codice in pairs:
        assert per_sigla.setdefault(sigla, codice) == codice, (
            f"sigla {sigla} mappata a più codici"
        )
        assert per_codice.setdefault(codice, sigla) == sigla, (
            f"codice {codice} mappato a più sigle"
        )


@pytest.mark.contract
def test_lookup_province_golden():
    """Coppie note: bloccano un errore di una cifra sul lookup a mano."""
    pairs = {provincia: (sigla, codice) for provincia, sigla, codice in _lookup_pairs()}
    golden = {
        "ROMA": ("RM", "058"),
        "MILANO": ("MI", "015"),
        "TORINO": ("TO", "001"),
        "NAPOLI": ("NA", "063"),
        "MACERATA": ("MC", "043"),
        "ASCOLI PICENO": ("AP", "044"),
        "PESARO E URBINO": ("PU", "041"),
        "L'AQUILA": ("AQ", "066"),
        "BOLZANO": ("BZ", "021"),
        "AOSTA": ("AO", "007"),
        "CAGLIARI": ("CA", "118"),
        "GALLURA NORD-EST SARDEGNA": ("OT", "113"),
        "OGLIASTRA": ("OG", "116"),
        "MEDIO CAMPIDANO": ("VS", "117"),
        "SULCIS IGLESIENTE": ("CI", "119"),
    }
    for provincia, atteso in golden.items():
        assert pairs.get(provincia) == atteso, (
            f"{provincia}: atteso {atteso}, trovato {pairs.get(provincia)}"
        )
