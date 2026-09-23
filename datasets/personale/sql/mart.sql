-- mart_personale_distribuzione.sql
-- DOMANDA: Come si distribuisce il personale per qualifica? Quanto è femminilizzato?
-- Output: distribuzione per qualifica con tasso femminilizzazione

SELECT
    anno,
    codice_qualifica,
    MAX(desc_qualifica) AS desc_qualifica,
    SUM(numero) AS totale,
    ROUND(100.0 * SUM(CASE WHEN genere = 'F' THEN numero ELSE 0 END) / NULLIF(SUM(numero), 0), 1) AS pct_donne,
    ROUND(100.0 * SUM(numero) / SUM(SUM(numero)) OVER (PARTITION BY anno), 1) AS share_totale
FROM clean_input
GROUP BY anno, codice_qualifica
ORDER BY anno, codice_qualifica
