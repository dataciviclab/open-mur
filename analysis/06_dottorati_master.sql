-- 06_dottorati_master.sql
-- Confronto iscritti dottorati vs master I per ateneo
-- Uso: orientamento della formazione post-laurea

SELECT
    livello,
    COUNT(DISTINCT ateneo_cod) AS n_atenei,
    SUM(totale) AS totale_iscritti,
    ROUND(100.0 * SUM(donne) / NULLIF(SUM(totale), 0), 1) AS pct_donne
FROM read_parquet('out/data/mart/mur_formazione_post_laurea/*/mart_post_laurea_ateneo.parquet')
GROUP BY livello
ORDER BY livello
