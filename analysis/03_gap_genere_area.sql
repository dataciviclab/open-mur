-- 03_gap_genere_area.sql
-- Gap di genere per area disciplinare (classi di laurea)
-- Uso: quali aree sono più paritarie e quali no

SELECT
    classe_cod,
    classe_nome,
    SUM(totale) AS totale_criticato,
    ROUND(100.0 * SUM(donne) / NULLIF(SUM(totale), 0), 1) AS pct_donne,
    CASE
        WHEN 100.0 * SUM(donne) / NULLIF(SUM(totale), 0) > 60 THEN 'fortemente femminile'
        WHEN 100.0 * SUM(donne) / NULLIF(SUM(totale), 0) > 52 THEN 'leggermente femminile'
        WHEN 100.0 * SUM(donne) / NULLIF(SUM(totale), 0) > 48 THEN 'paritario'
        WHEN 100.0 * SUM(donne) / NULLIF(SUM(totale), 0) > 40 THEN 'leggermente maschile'
        ELSE 'fortemente maschile'
    END AS bilanciamento
FROM read_parquet('out/data/mart/mur_immatricolati/*/mart_immatricolati.parquet')
WHERE anno >= 2020
GROUP BY classe_cod, classe_nome
HAVING SUM(totale) > 100
ORDER BY pct_donne DESC
