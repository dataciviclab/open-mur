-- 07_gettito_contribuzione.sql
-- Gettito contribuzione studentesca per tipo (serie storica)
-- Uso: come si finanzia il sistema universitario

SELECT
    anno,
    descrizione_gettito,
    SUM(totale_euro) AS totale_euro,
    ROUND(SUM(totale_euro) / 1000000, 1) AS milioni_euro
FROM read_parquet('out/data/mart/mur_contribuzione_universitaria/*/mart_gettito_ateneo_tipo.parquet')
GROUP BY anno, descrizione_gettito
ORDER BY anno, descrizione_gettito
