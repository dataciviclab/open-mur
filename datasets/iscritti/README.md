# MUR — Iscritti Universitari

**Fonte**: Ministero dell'Università e della Ricerca, Ufficio Statistico (USTAT)

**Dataset**: Iscritti per ateneo (2000–2025)

**URL**: http://dati.ustat.miur.it/

**Colonne**: AnnoA, AteneoNOME, AteneoCOD, SESSO, Isc

**Encoding**: latin-1, delimitatore `;`

## Note

- Portale CKAN instabile, accesso via HTTP (non HTTPS). Usato `http_file` con URL CSV diretto.
- API DataStore spesso restituisce 404 per risorse CSV. Download diretto via HTTPS funziona.
- La serie **non contiene il 2009** (gap anagrafico MUR): non è un errore di pipeline e non va interpolato.
