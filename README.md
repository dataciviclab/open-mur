# open-mur — Intelligence sulle università italiane

Dati aperti sul sistema universitario italiano. Fonte primaria: MUR/USTAT via [dati-ustat.mur.gov.it](https://dati-ustat.mur.gov.it).

## Dataset

### Principali

| Dataset | Slug | Granularità | Copertura | Mart |
|---------|------|-------------|-----------|------|
| Contribuzione universitaria | `contribuzione-universitaria` | Ateneo × tipo gettito × anno | 2017–2024 | `mart_contribuzione_trend` |
| Immatricolati | `immatricolati` | Classe laurea × sesso × anno | 1998–2025 | `mart_immatricolati_area` |
| Iscritti | `iscritti` | Ateneo × sesso × anno | 2000–2025 | `mart_iscritti_concentrazione` |
| Laureati | `laureati` | Ateneo × sesso × anno | 2001–2025 | `mart_laureati_efficienza` |
| Laureati per voto | `laureati-voto` | Ateneo × voto × genere × anno | 2014–2024 | `mart_laureati_per_voto`, `mart_voto_per_ateneo` |
| Personale nazionale | `personale` | Genere × qualifica × anno | 1997–2024 | `mart_personale_distribuzione` |
| Personale per ateneo | `personale-ateneo` | Ateneo × grade × genere × anno | 2012–2024 | `mart_personale_per_ateneo`, `mart_personale_per_grade` |
| Formazione post-laurea | `formazione-post-laurea` | Ateneo × livello × sesso × anno | 2001–2024 | `mart_post_laurea_area` |

### Support

| Dataset | Slug | Contenuto |
|---------|------|-----------|
| Anagrafica atenei | `anagrafica-atenei` | Codice, nome, tipo, città, provincia, regione, macro-area |
| Crosswalk STEM | `crosswalk-stem` | Classi di laurea → ISCED-F 2013 con flag STEM |
| Tasso abbandono | `tasso-abbandono` | Tasso di abbandono entro il 1° anno, serie storica 2011–2025 |
| Offerta formativa | `offerta-formativa` | Elenco corsi di laurea per ateneo, classe, sede, lingua |

## Note sui dati

- Tutti i CSV MUR usano **punto e virgola** (`;`) come delimitatore e **line ending Windows** (`\r\n`)
- Le colonne anno accademico sono nel formato `AAAA/AAAA` (es. `2024/2025`) — il clean.sql estrae l'anno di inizio
- `personale` è una serie storica nazionale (non per-ateneo)
- `formazione-post-laurea` include dottorati e master I livello

## Setup

```bash
# Clona il repo
git clone https://github.com/dataciviclab/open-mur.git
cd open-mur

# Installa dipendenze di sviluppo
pip install -e ".[dev]"

# Verifica configurazioni
make check

# Esegui tutti i dataset
make run

# Esegui un singolo dataset
toolkit run --config datasets/laureati/dataset.yml
```

## Struttura

```
open-mur/
├── datasets/                    Dataset principali (raw → clean → mart)
│   ├── contribuzione-universitaria/
│   ├── crosswalk-stem/
│   ├── formazione-post-laurea/
│   ├── immatricolati/
│   ├── iscritti/
│   ├── laureati/
│   ├── laureati-voto/
│   ├── personale/
│   └── personale-ateneo/
├── support/                     Dataset di supporto
│   ├── anagrafica-atenei/
│   ├── offerta-formativa/
│   └── tasso-abbandono/
├── analysis/                    Script di analisi SQL
├── tests/                       Test suite
├── out/                         Output pipeline (git-ignored)
├── Makefile                     Target: check, run, clean
├── pyproject.toml               Configurazione progetto
├── CONTRIBUTING.md              Guida ai contributi
└── LICENSE                      MIT
```

## Analisi

Gli script in `analysis/` eseguono query SQL sui mart e producono CSV:

```bash
python analysis/run_analysis.py
```

Query disponibili:
1. Trend iscrizioni
2. Classifica atenei
3. Gap genere per area
4. Tasso completamento
5. Docenti per qualifica
6. Dottorati e master
7. Gettito contribuzione
8. Equilibrio geografico

## Fonti non ancora nel Lab

| Fonte | Contenuto | Potenziale |
|-------|-----------|------------|
| ANVUR Cruscotto | Indicatori per ateneo | Alto — ma Power BI, non CSV statico |
| MUR Personale per ateneo | Docenti per ateneo e qualifica (2020–2024) | Alto |
| MUR Bilancio atenei | Preventivo/consuntivo | Medio — formato XLSX |

## License

MIT — vedi [LICENSE](LICENSE).
