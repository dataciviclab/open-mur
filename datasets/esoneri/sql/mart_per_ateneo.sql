-- mart_esoneri_per_ateneo
-- DOMANDA: quanti studenti sono esonerati per ateneo e tipo di esonero?

SELECT
    anno_accademico,
    cod_ateneo,
    nome_ateneo,
    macro_area,
    regione,
    tipo_esonero,
    SUM(totale) AS totale
FROM clean_input
GROUP BY anno_accademico, cod_ateneo, nome_ateneo, macro_area, regione, tipo_esonero
ORDER BY anno_accademico, tipo_esonero, totale DESC
