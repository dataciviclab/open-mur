# Contribuire a open-mur

Grazie per il tuo interesse a contribuire a open-mur!

## Setup locale

```bash
# Clona il repo
git clone https://github.com/dataciviclab/open-mur.git
cd open-mur

# Installa le dipendenze di sviluppo
pip install -e ".[dev]"

# Verifica che tutto funzioni
make check
make run
```

## Struttura del progetto

```
open-mur/
├── datasets/           Dataset principali (raw → clean → mart)
├── support/            Dataset di supporto (anagrafica, crosswalk)
├── analysis/           Script di analisi SQL
├── out/                Output pipeline (git-ignored)
├── Makefile            Target: check, run, clean
└── pyproject.toml      Configurazione progetto
```

## Aggiungere un nuovo dataset

1. Crea la directory in `datasets/<nome-dataset>/`
2. Crea `dataset.yml` seguendo il template:
   - `schema_version: 1`
   - `root: "../../out"`
   - Configurazioni `raw`, `clean`, `mart`, `validation`
3. Crea `sql/clean.sql` e `sql/mart.sql`
4. Esegui `toolkit run --config datasets/<nome-dataset>/dataset.yml`
5. Verifica che `make check` passi

## Standard di codice

- **SQL**: usa macro toolkit quando possibile (`{{ select_source(...) }}`)
- **Test**: ogni test ha un marker (`@pytest.mark.<marker>`)
- **Commit**: messaggi descrittivi, un commit per cambiamento logico

## Checklist pre-PR

- [ ] `make check` passa
- [ ] `pytest tests/ -v` passa
- [ ] Nuovi dataset hanno `dataset.yml` + SQL
- [ ] Test hanno marker appropriati
- [ ] README aggiornato se necessario

## Domande?

Apri una [GitHub Discussion](https://github.com/dataciviclab/open-mur/discussions) o commenta nella PR.
