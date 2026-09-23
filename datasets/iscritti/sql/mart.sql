-- mart_iscritti_concentrazione.sql
-- DOMANDA: Quanto è concentrato il sistema universitario? Quali zone dominano?
-- Output: iscritti per macro-area con quota + classifica atenei

SELECT
    anno,
    ateneo_cod,
    ateneo_nome,
    macro_area,
    regione,
    SUM(iscritti) AS totale,
    SUM(CASE WHEN sesso = 'F' THEN iscritti ELSE 0 END) AS donne,
    SUM(CASE WHEN sesso = 'M' THEN iscritti ELSE 0 END) AS uomini,
    ROUND(100.0 * SUM(CASE WHEN sesso = 'F' THEN iscritti ELSE 0 END) / NULLIF(SUM(iscritti), 0), 1) AS pct_donne,
    ROUND(100.0 * SUM(iscritti) / SUM(SUM(iscritti)) OVER (PARTITION BY anno), 1) AS share_nazionale,
    RANK() OVER (PARTITION BY anno ORDER BY SUM(iscritti) DESC) AS ranking
FROM clean_input
GROUP BY anno, ateneo_cod, ateneo_nome, macro_area, regione
ORDER BY anno, ranking
