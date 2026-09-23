-- mart_laureati_efficienza.sql
-- DOMANDA: Quali atenei laureano di più? Come si distribuiscono geograficamente?
-- Output: laureati per ateneo con quota + ranking

SELECT
    anno,
    ateneo_cod,
    ateneo_nome,
    macro_area,
    regione,
    SUM(laureati) AS totale,
    SUM(CASE WHEN sesso = 'F' THEN laureati ELSE 0 END) AS donne,
    SUM(CASE WHEN sesso = 'M' THEN laureati ELSE 0 END) AS uomini,
    ROUND(100.0 * SUM(CASE WHEN sesso = 'F' THEN laureati ELSE 0 END) / NULLIF(SUM(laureati), 0), 1) AS pct_donne,
    ROUND(100.0 * SUM(laureati) / SUM(SUM(laureati)) OVER (PARTITION BY anno), 1) AS share_nazionale,
    RANK() OVER (PARTITION BY anno ORDER BY SUM(laureati) DESC) AS ranking
FROM clean_input
GROUP BY anno, ateneo_cod, ateneo_nome, macro_area, regione
ORDER BY anno, ranking
