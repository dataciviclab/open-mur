-- 04_tasso_completamento.sql
-- Rapporto laureati/iscritti per ateneo (tasso di completamento indicativo)
-- Nota: laureati di un anno corrispondono a iscritti di ~3-5 anni prima
-- Uso: efficienza degli atenei nel far laureare gli studenti

WITH laureati_recenti AS (
    SELECT ateneo_cod, ateneo_nome, SUM(totale) AS laureati
    FROM read_parquet('out/data/mart/mur_laureati/*/mart_laureati_ateneo.parquet')
    WHERE anno BETWEEN 2022 AND 2024
    GROUP BY ateneo_cod, ateneo_nome
),
iscritti_base AS (
    SELECT ateneo_cod, SUM(totale) AS iscritti
    FROM read_parquet('out/data/mart/mur_iscritti/*/mart_iscritti.parquet')
    WHERE anno BETWEEN 2018 AND 2020
    GROUP BY ateneo_cod
)
SELECT
    l.ateneo_cod,
    l.ateneo_nome,
    l.laureati,
    i.iscritti,
    ROUND(100.0 * l.laureati / NULLIF(i.iscritti, 0), 1) AS tasso_completamento
FROM laureati_recenti l
JOIN iscritti_base i ON l.ateneo_cod = i.ateneo_cod
WHERE i.iscritti > 500
ORDER BY tasso_completamento DESC
LIMIT 20
