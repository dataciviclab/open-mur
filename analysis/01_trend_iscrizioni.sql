-- 01_trend_iscrizioni.sql
-- Trend iscrizioni totali per anno (ultimi 10 anni)
-- Uso: capire se il sistema universitario cresce o decresce

SELECT
    anno,
    SUM(totale) AS iscritti_totali,
    SUM(donne) AS donne,
    SUM(uomini) AS uomini,
    ROUND(100.0 * SUM(donne) / NULLIF(SUM(totale), 0), 1) AS pct_donne
FROM read_parquet('out/data/mart/mur_iscritti/*/mart_iscritti.parquet')
WHERE anno >= 2015
GROUP BY anno
ORDER BY anno
