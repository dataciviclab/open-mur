-- 05_docenti_per_ateneo.sql
-- Composizione del personale per qualifica (serie storica nazionale)
-- Uso: evoluzione della struttura del personale accademico

SELECT
    anno,
    desc_qualifica,
    SUM(totale) AS totale,
    ROUND(100.0 * SUM(CASE WHEN genere = 'F' THEN totale ELSE 0 END) / NULLIF(SUM(totale), 0), 1) AS pct_donne
FROM read_parquet('out/data/mart/mur_personale/*/mart_personale_genere_qualifica.parquet')
WHERE anno >= 2010
GROUP BY anno, desc_qualifica
ORDER BY anno, desc_qualifica
