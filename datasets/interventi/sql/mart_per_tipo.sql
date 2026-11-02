-- mart_interventi_per_tipo
-- DOMANDA: quali tipi di intervento (borse, prestiti, altro) pesano di più?

SELECT
    anno_accademico,
    descrizione_intervento,
    SUM(totale) AS totale
FROM clean_input
GROUP BY anno_accademico, descrizione_intervento
ORDER BY anno_accademico, totale DESC
