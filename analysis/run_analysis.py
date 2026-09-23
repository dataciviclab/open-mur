#!/usr/bin/env python3
"""Esegui tutte le query di analisi e salva i risultati in CSV."""
import duckdb
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
MART = BASE / "out" / "data" / "mart"
OUT = BASE / "analysis" / "results"
OUT.mkdir(exist_ok=True)

QUERIES = [
    ("01_trend_iscrizioni", "01_trend_iscrizioni.sql"),
    ("02_classifica_atenei", "02_classifica_atenei.sql"),
    ("03_gap_genere_area", "03_gap_genere_area.sql"),
    ("04_tasso_completamento", "04_tasso_completamento.sql"),
    ("05_docenti_per_qualifica", "05_docenti_per_qualifica.sql"),
    ("06_dottorati_master", "06_dottorati_master.sql"),
    ("07_gettito_contribuzione", "07_gettito_contribuzione.sql"),
    ("08_equilibrio_geografico", "08_equilibrio_geografico.sql"),
]

con = duckdb.connect()
for name, sql_file in QUERIES:
    sql_path = BASE / "analysis" / sql_file
    if not sql_path.exists():
        print(f"  SKIP {sql_file} (non trovato)")
        continue
    sql = sql_path.read_text()
    try:
        result = con.execute(sql).fetchdf()
        out_path = OUT / f"{name}.csv"
        result.to_csv(out_path, index=False)
        print(f"  OK  {name}: {len(result)} righe -> {out_path.name}")
    except Exception as e:
        print(f"  ERR {name}: {e}")

con.close()
print(f"\nRisultati in {OUT}/")
