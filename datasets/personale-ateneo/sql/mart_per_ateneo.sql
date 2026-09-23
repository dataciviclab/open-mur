-- mart_personale_per_ateneo.sql
-- DOMANDA: Quali atenei hanno più personale? Come si distribuisce per grade?
-- Output: personale per ateneo con quota + distribuzione grade

SELECT
    anno,
    cod_ateneo,
    nome_ateneo,
    macro_area,
    grade,
    genere,
    SUM(numero) AS totale,
    ROUND(100.0 * SUM(numero) / SUM(SUM(numero)) OVER (PARTITION BY anno, cod_ateneo), 1) AS share_ateneo
FROM clean_input
GROUP BY anno, cod_ateneo, nome_ateneo, macro_area, grade, genere
ORDER BY anno, cod_ateneo, grade, genere
