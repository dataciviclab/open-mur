-- mart_laureati_per_voto.sql
-- DOMANDA: Come si distribuiscono i voti di laurea? C'è inflazione?
-- Output: distribuzione voti con quota per anno

SELECT
    anno,
    classe_voto,
    genere,
    SUM(laureati) AS totale,
    ROUND(100.0 * SUM(laureati) / SUM(SUM(laureati)) OVER (PARTITION BY anno), 1) AS pct_anno,
    ROUND(100.0 * SUM(laureati) / SUM(SUM(laureati)) OVER (PARTITION BY anno, genere), 1) AS pct_genere
FROM clean_input
GROUP BY anno, classe_voto, genere
ORDER BY anno, classe_voto, genere
