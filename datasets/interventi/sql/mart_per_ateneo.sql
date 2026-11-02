-- mart_interventi_per_ateneo
-- DOMANDA: quanti sostegni/borse eroga ogni ateneo?

SELECT
    anno_accademico,
    cod_ateneo,
    nome_ateneo,
    macro_area,
    regione,
    SUM(totale) AS totale
FROM clean_input
GROUP BY anno_accademico, cod_ateneo, nome_ateneo, macro_area, regione
ORDER BY anno_accademico, totale DESC
