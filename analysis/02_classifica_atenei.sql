-- 02_classifica_atenei.sql
-- Classifica top 20 atenei per iscritti (anno più recente)
-- Uso: dimensione relativa degli atenei

SELECT
    ateneo_cod,
    ateneo_nome,
    totale AS iscritti,
    donne,
    uomini,
    pct_donne
FROM read_parquet('out/data/mart/mur_iscritti/*/mart_iscritti.parquet')
WHERE anno = (SELECT MAX(anno) FROM read_parquet('out/data/mart/mur_iscritti/*/mart_iscritti.parquet'))
ORDER BY totale DESC
LIMIT 20
