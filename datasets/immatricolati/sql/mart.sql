-- mart_immatricolati_area.sql
-- DOMANDA: Quali aree disciplinari attirano più studenti? Come cambia il gap di genere?
-- Output: top aree per volume + evoluzione gap

SELECT
    anno,
    classe_cod,
    MAX(classe_nome) AS classe_nome,
    SUM(immatricolati) AS totale,
    SUM(CASE WHEN sesso = 'F' THEN immatricolati ELSE 0 END) AS donne,
    SUM(CASE WHEN sesso = 'M' THEN immatricolati ELSE 0 END) AS uomini,
    ROUND(100.0 * SUM(CASE WHEN sesso = 'F' THEN immatricolati ELSE 0 END) / NULLIF(SUM(immatricolati), 0), 1) AS pct_donne,
    ROUND(100.0 * SUM(immatricolati) / SUM(SUM(immatricolati)) OVER (PARTITION BY anno), 1) AS share_totale
FROM clean_input
GROUP BY anno, classe_cod
ORDER BY anno, totale DESC
