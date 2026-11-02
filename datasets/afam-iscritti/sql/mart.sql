-- mart_afam_iscritti_area
-- DOMANDA: come si distribuiscono gli iscritti AFAM per area disciplinare?
-- Output: iscritti per anno accademico e area del corso, con gap di genere e quota.

SELECT
    anno_accademico,
    area_corso,
    SUM(iscritti) AS totale,
    SUM(CASE WHEN genere = 'F' THEN iscritti ELSE 0 END) AS donne,
    SUM(CASE WHEN genere = 'M' THEN iscritti ELSE 0 END) AS uomini,
    ROUND(
        100.0 * SUM(CASE WHEN genere = 'F' THEN iscritti ELSE 0 END)
        / NULLIF(SUM(iscritti), 0),
        1
    ) AS pct_donne,
    ROUND(
        100.0 * SUM(iscritti) / SUM(SUM(iscritti)) OVER (PARTITION BY anno_accademico),
        1
    ) AS share_anno
FROM clean_input
GROUP BY anno_accademico, area_corso
ORDER BY anno_accademico, totale DESC
