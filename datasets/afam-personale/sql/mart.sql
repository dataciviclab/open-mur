-- mart_afam_personale
-- DOMANDA: come è composto il personale AFAM (docente vs ATA) e con quale gap di genere?
-- Output: numero per anno accademico, tipo di personale e genere.

SELECT
    anno_accademico,
    tipo_personale,
    genere,
    SUM(numero) AS totale
FROM clean_input
GROUP BY anno_accademico, tipo_personale, genere
ORDER BY anno_accademico, tipo_personale, genere
