-- mart_esoneri_per_causa
-- DOMANDA: quali cause di esonero pesano di più (borse, disabilità, reddito...)?

SELECT
    anno_accademico,
    tipo_esonero,
    descrizione_esonero,
    SUM(totale) AS totale
FROM clean_input
GROUP BY anno_accademico, tipo_esonero, descrizione_esonero
ORDER BY anno_accademico, tipo_esonero, totale DESC
