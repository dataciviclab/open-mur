"""Query SQL — Interroga direttamente i dati."""

from pathlib import Path

from lab_connectors.duckdb.sql_page import render_sql_query
from sources import _registry

render_sql_query(
    registry=_registry,
    default_slug="mur_iscritti",
    title="Query SQL",
    description=(
        "Interroga direttamente i dati. Scrivi SQL su ``clean_input`` — "
        "viene risolta automaticamente sui Parquet."
    ),
)
