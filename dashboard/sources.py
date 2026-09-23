"""Data sources per la dashboard open-mur.

Wrappa lab_connectors con @st.cache_data.
"""

from __future__ import annotations

from pathlib import Path

import streamlit as st

from lab_connectors.duckdb.queries import load_mart_table
from lab_connectors.formatters import fmt_eur, fmt_num, fmt_pct
from lab_connectors.registry import load_registry

__all__ = ["fmt_eur", "fmt_num", "fmt_pct", "load_mart", "run_sql", "YEARS"]

_registry = load_registry(Path(__file__).parent.parent / "registry" / "registry.json")

# Anni disponibili: union di tutti i period nel registry
_all_start = []
_all_end = []
for ds in _registry.datasets:
    p = ds.period or {}
    s = p.get("start")
    e = p.get("end")
    if s is not None:
        _all_start.append(int(s))
    if e is not None:
        _all_end.append(int(e))
YEARS = list(range(min(_all_start), max(_all_end) + 1)) if _all_start and _all_end else []


@st.cache_data(ttl=3600, show_spinner=False)
def load_mart(slug: str, table: str, year: int) -> "pd.DataFrame":
    """Carica un mart table da GCS o locale (cached 1h)."""
    return load_mart_table(slug, table, year)


@st.cache_data(ttl=3600, show_spinner=False)
def run_sql(sql: str) -> "pd.DataFrame":
    """Esegue SQL arbitrario sui parquet via DuckDB (cached 1h)."""
    import duckdb
    with duckdb.connect() as con:
        return con.sql(sql).df()
