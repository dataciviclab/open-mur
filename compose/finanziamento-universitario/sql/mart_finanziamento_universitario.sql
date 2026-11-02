-- mart_finanziamento_universitario
-- Grano: anno.
-- SIOPE: comparto UNI, cassa (entrate/uscite), 2021-2026.
-- BDAP: missione 023 "Istruzione universitaria e formazione post-universitaria",
--       competenza (previsioni iniziali CS), 2017-2026.
-- ATTENZIONE: cassa e competenza sono basi contabili diverse. Le colonne
-- restano separate e NON vanno sommate.

WITH siope AS (
    SELECT
        anno,
        SUM(CASE WHEN lato = 'entrate' THEN importo_eur ELSE 0 END) AS siope_entrate_eur,
        SUM(CASE WHEN lato = 'uscite' THEN importo_eur ELSE 0 END) AS siope_uscite_eur,
        COUNT(DISTINCT codice_ente) AS siope_enti
    FROM read_parquet({support.siope.clean})
    WHERE codice_comparto = 'UNI'
    GROUP BY anno
),
bdap AS (
    SELECT
        esercizio_finanziario AS anno,
        SUM(COALESCE(previsioni_iniziali_cs, 0)) AS bdap_spese_eur
    FROM read_parquet({support.bdap.clean})
    WHERE codice_missione = '023'
    GROUP BY esercizio_finanziario
)
SELECT
    COALESCE(s.anno, b.anno) AS anno,
    s.siope_entrate_eur,
    s.siope_uscite_eur,
    s.siope_enti,
    b.bdap_spese_eur,
    'SIOPE=cassa; BDAP=competenza' AS nota_base
FROM siope s
FULL OUTER JOIN bdap b ON s.anno = b.anno
ORDER BY anno
