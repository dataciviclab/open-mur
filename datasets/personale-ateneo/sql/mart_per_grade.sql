-- mart_personale_per_grade.sql
-- DOMANDA: C'è soffitto di vetro? Come cambia il gap di genere per livello di carriera?
-- Output: distribuzione per grade con gap di genere

SELECT
    anno,
    grade,
    SUM(numero) AS totale,
    SUM(CASE WHEN genere = 'F' THEN numero ELSE 0 END) AS donne,
    SUM(CASE WHEN genere = 'M' THEN numero ELSE 0 END) AS uomini,
    ROUND(100.0 * SUM(CASE WHEN genere = 'F' THEN numero ELSE 0 END) / NULLIF(SUM(numero), 0), 1) AS pct_donne,
    ROUND(100.0 * SUM(numero) / SUM(SUM(numero)) OVER (PARTITION BY anno), 1) AS share_totale
FROM clean_input
WHERE cod_ateneo != 'TTTTT'
GROUP BY anno, grade
ORDER BY anno, grade
