-- mart_post_laurea_area.sql
-- DOMANDA: Come si distribuiscono dottorati e master per area geografica?
-- Output: quota dottorati/master per macro-area con evoluzione

SELECT
    anno_accademico,
    macro_area,
    livello,
    SUM(iscritti) AS totale,
    SUM(CASE WHEN sesso = 'F' THEN iscritti ELSE 0 END) AS donne,
    SUM(CASE WHEN sesso = 'M' THEN iscritti ELSE 0 END) AS uomini,
    ROUND(100.0 * SUM(CASE WHEN sesso = 'F' THEN iscritti ELSE 0 END) / NULLIF(SUM(iscritti), 0), 1) AS pct_donne,
    ROUND(100.0 * SUM(iscritti) / SUM(SUM(iscritti)) OVER (PARTITION BY anno_accademico, livello), 1) AS share_livello,
    ROUND(100.0 * SUM(iscritti) / SUM(SUM(iscritti)) OVER (PARTITION BY anno_accademico, macro_area), 1) AS share_area
FROM clean_input
GROUP BY anno_accademico, macro_area, livello
ORDER BY anno_accademico, macro_area, livello
