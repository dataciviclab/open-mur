-- mart_afam_diplomati_area
-- DOMANDA: quali aree AFAM sfornano più diplomati e con quale gap di genere?
-- Output: diplomati per anno e area del corso, con quota e gap di genere.

SELECT
    anno,
    area_corso,
    SUM(diplomati) AS totale,
    SUM(CASE WHEN genere = 'F' THEN diplomati ELSE 0 END) AS donne,
    SUM(CASE WHEN genere = 'M' THEN diplomati ELSE 0 END) AS uomini,
    ROUND(
        100.0 * SUM(CASE WHEN genere = 'F' THEN diplomati ELSE 0 END)
        / NULLIF(SUM(diplomati), 0),
        1
    ) AS pct_donne,
    ROUND(
        100.0 * SUM(diplomati) / SUM(SUM(diplomati)) OVER (PARTITION BY anno),
        1
    ) AS share_anno
FROM clean_input
GROUP BY anno, area_corso
ORDER BY anno, totale DESC
