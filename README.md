# open-mur — L'università italiana, aperta e interrogabile

[![CI](https://github.com/dataciviclab/open-mur/actions/workflows/check.yml/badge.svg)](https://github.com/dataciviclab/open-mur/actions/workflows/check.yml)

**2 milioni di iscritti, 92 atenei e 96mila studenti AFAM, 30 anni di dati. Tutto interrogabile via SQL.**

open-mur raccoglie e rende pubblici i dati del sistema universitario italiano dalla fonte primaria [MUR/USTAT](https://dati-ustat.mur.gov.it). Iscritti, laureati, personale, contribuzione studentesca — e dal 2026 anche **AFAM** (Accademie, Conservatori, ISIA) — puliti, arricchiti e pronti per l'analisi.

## Cosa contiene

| | |
|---|---|
| **Dataset** | 18 (9 principali + 3 support + 3 AFAM + 1 support AFAM + 2 diritto allo studio) |
| **Periodo** | 1997 — 2025 (varia per dataset) |
| **Atenei** | 112 in anagrafica · 92 con iscritti nel 2025 |
| **Istituti AFAM** | 204 in anagrafica |
| **Formato** | Parquet su GCS |

### Per tema

| Tema | Esempi |
|------|--------|
| 📚 Iscrizioni | Trend iscritti per ateneo, distribuzione geografica |
| 🎓 Laureati | Tasso di completamento, voto di laurea |
| ⚖️ Genere | Gap STEM, distribuzione per disciplina |
| 👩‍🏫 Personale | Qualifiche, evoluzione storica, bilancio di genere |
| 💰 Finanza | Gettito contribuzione studentesca per tipo |
| 📉 Efficienza | Tasso di abbandono, concentrazione geografica |
| 🎼 AFAM | Iscritti, diplomati e personale di accademie e conservatori (2010–2025) |

> **Nota geografica.** `provincia` è la provincia della **sede dell'ateneo** (costante per ateneo), non la residenza degli studenti. Non usarla come chiave di join su dati di studenti: per i join usare `cod_ateneo`, per la geografia `regione` o `macro_area`. L'anagrafica espone anche `sigla_provincia` e `cod_provincia_istat` per gli usi descrittivi.
>
> **Nota serie iscritti.** La serie 2000–2025 non contiene il 2009: è un gap anagrafico della fonte MUR, non un errore di pipeline. Non va interpolato.
>
> **Nota AFAM.** `cod_istituto` non è univoco nell'anagrafica (6 codici hanno più sedi): il join nei dataset usa una riga per codice per evitare fan-out. `anno_accademico` è l'anno di inizio (es. 2025 = a.a. 2025/26); i diplomati usano invece l'anno solare.
>
> **Copertura AFAM.** Il nome istituto arriva dalla fonte, non dal join: **~89,5%** delle righe iscritti ha un nome (il 10,5% è vuoto nella fonte). **4 codici** iscritti non sono nell'anagrafica 2025 — `59050`, `59070` (sedi decentrate), `59090` (nuovo codice post-statizzazione del Politecnico di Bergamo), `72391` (sezione storica) — per **164 righe, ~1,2% degli iscritti**. Il mart aggrega per area e non ne risente; per un'analisi per istituto va considerata la copertura.

## AFAM in breve

| Dataset | Contenuto | Periodo |
|---|---|---|
| `mur_afam_iscritti` | Iscritti per istituto, corso e genere | 2010–2025 |
| `mur_afam_diplomati` | Diplomati per istituto, corso e genere | 2010–2025 |
| `mur_afam_personale` | Personale docente e ATA per qualifica e genere | 2010–2025 |
| `mur_afam_istituti` | Anagrafica istituti (support) | 2025 |

## Diritto allo studio (lato MUR)

| Dataset | Contenuto | Periodo |
|---|---|---|
| `mur_esoneri` | Studenti esonerati (totali e parziali) per ateneo e causa | a.a. 2015/16–2024/25 |
| `mur_interventi` | Interventi in favore degli studenti (borse di studio, sostegni) | a.a. 2015/16–2024/25 |

> Questi dataset leggono il **CSV diretto** (`prefer_datastore: false`): il DataStore MUR è incompleto su alcuni anni (es. interventi 2020: 1.250 righe nel DataStore vs 2.530 nel CSV) e su alcune risorse non è attivo.

## Esempi di domande

- **Il sistema universitario italiano cresce o decresce?** (Trend iscritti 2000–2025)
- **Quali atenei sono più grandi?** E quali hanno il tasso di completamento più alto?
- **Dove le donne sono sottorappresentate nelle discipline?** (Gap STEM per classe di laurea)
- **Nord o Sud?** Come si distribuiscono gli studenti nelle macro-aree?
- **Quanto costa l'università agli studenti?** (Gettito contribuzione per tipo)

## Dashboard

Una [dashboard Streamlit](dashboard/) visualizza i dati per tema:

- **Panoramica** — KPI + trend iscritti + top 10 atenei + distribuzione geografica
- **Atenei** — classifica per dimensione + scheda singolo ateneo
- **Genere & STEM** — gap per disciplina + classi più femminili/maschili
- **Geografia** — distribuzione macro-area + concentrazione
- **Personale** — composizione per qualifica + evoluzione temporale
- **Finanza** — gettito contribuzione + trend
- **Query SQL** — interrogazione diretta dei dati

```bash
cd dashboard && pip install -r requirements.txt && streamlit run app.py
```

## Tre modi per accedere ai dati

### 1. Via MCP (toolkit del Lab)

```bash
toolkit query mur_iscritti "SELECT ateneo_nome, SUM(totale) AS iscritti FROM clean_input GROUP BY ateneo_nome ORDER BY iscritti DESC LIMIT 10"
```

### 2. Via DuckDB locale

```bash
duckdb -c "SELECT * FROM read_parquet('out/data/mart/mur_iscritti/2025/mart_iscritti_concentrazione.parquet') WHERE anno = 2025 LIMIT 10"
```

### 3. Via parquet su GCS

Scarica i file da `gs://dataciviclab-mart/open-mur/` e aprili con qualsiasi tool (pandas, Polars, Excel).

## Setup locale

```bash
git clone https://github.com/dataciviclab/open-mur.git
cd open-mur
pip install -e ".[dev]"
make check
make run
```

## Partecipa

- 💬 [Discussions](https://github.com/orgs/dataciviclab/discussions) — domande, suggerimenti, idee
- 🐛 [Issue](https://github.com/dataciviclab/open-mur/issues) — bug, dataset mancanti, miglioramenti
- 🔧 [CONTRIBUTING.md](CONTRIBUTING.md) — come contribuire

## License

MIT — vedi [LICENSE](LICENSE).
