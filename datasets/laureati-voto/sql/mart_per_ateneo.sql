-- mart_voto_per_ateneo.sql
-- DOMANDA: Quali atenei hanno voti più alti? Dove si laurea meglio?
-- Output: distribuzione voti per ateneo con media ponderata proxy

SELECT
    anno,
    cod_ateneo,
    nome_ateneo,
    macro_area,
    classe_voto,
    SUM(laureati) AS totale,
    SUM(CASE WHEN genere = 'F' THEN laureati ELSE 0 END) AS donne,
    SUM(CASE WHEN genere = 'M' THEN laureati ELSE 0 END) AS uomini,
    -- Peso proxy per voto medio (110e lode=110, 101-105=103, ecc.)
    SUM(laureati * CASE classe_voto
        WHEN '110 e lode' THEN 110
        WHEN '106-110' THEN 108
        WHEN '101-105' THEN 103
        WHEN '91-100' THEN 95.5
        WHEN '66-90' THEN 78
        ELSE 100
    END) AS voto_ponderato_sum,
    SUM(laureati) AS voto_ponderato_den
FROM clean_input
GROUP BY anno, cod_ateneo, nome_ateneo, macro_area, classe_voto
ORDER BY anno, cod_ateneo, classe_voto
