-- 08_equilibrio_geografico.sql
-- Distribuzione iscritti per macro-area geografica
-- Uso: concentrazione degli studenti nel Nord vs Sud

WITH atenei_area AS (
    SELECT
        *,
        CASE
            WHEN ateneo_nome LIKE '%Torino%' OR ateneo_nome LIKE '%Milano%' OR ateneo_nome LIKE '%Pavia%' OR ateneo_nome LIKE '%Bergamo%' OR ateneo_nome LIKE '%Brescia%' OR ateneo_nome LIKE '%Insubria%' OR ateneo_nome LIKE '%Vercelli%' OR ateneo_nome LIKE '%Eastern%' THEN 'Nord-Ovest'
            WHEN ateneo_nome LIKE '%Genova%' OR ateneo_nome LIKE '%Trieste%' OR ateneo_nome LIKE '%Udine%' OR ateneo_nome LIKE '%Verona%' OR ateneo_nome LIKE '%Padova%' OR ateneo_nome LIKE '%Venezia%' OR ateneo_nome LIKE '%Ferrara%' OR ateneo_nome LIKE '%Bologna%' OR ateneo_nome LIKE '%Parma%' OR ateneo_nome LIKE '%Modena%' OR ateneo_nome LIKE '%Reggio Emilia%' OR ateneo_nome LIKE '%Piacenza%' OR ateneo_nome LIKE '%San Marino%' THEN 'Nord-Est'
            WHEN ateneo_nome LIKE '%Roma%' THEN 'Centro-Roma'
            WHEN ateneo_nome LIKE '%Firenze%' OR ateneo_nome LIKE '%Pisa%' OR ateneo_nome LIKE '%Siena%' OR ateneo_nome LIKE '%Arezzo%' OR ateneo_nome LIKE '%Macerata%' OR ateneo_nome LIKE '%Urbino%' OR ateneo_nome LIKE '%Ancona%' OR ateneo_nome LIKE '%Perugia%' OR ateneo_nome LIKE '%Camerino%' THEN 'Centro-Marche-Umbria'
            WHEN ateneo_nome LIKE '%Napoli%' OR ateneo_nome LIKE '%Salerno%' OR ateneo_nome LIKE '%Benevento%' OR ateneo_nome LIKE '%Caserta%' OR ateneo_nome LIKE '%Sannio%' THEN 'Sud-Campania'
            WHEN ateneo_nome LIKE '%Bari%' OR ateneo_nome LIKE '%Lecce%' OR ateneo_nome LIKE '%Foggia%' OR ateneo_nome LIKE '%Taranto%' OR ateneo_nome LIKE '%Brindisi%' OR ateneo_nome LIKE '%Andria%' OR ateneo_nome LIKE '%Barletta%' OR ateneo_nome LIKE '%Trani%' OR ateneo_nome LIKE '%Casamassima%' THEN 'Sud-Puglia'
            WHEN ateneo_nome LIKE '%Catania%' OR ateneo_nome LIKE '%Palermo%' OR ateneo_nome LIKE '%Messina%' OR ateneo_nome LIKE '%Cagliari%' OR ateneo_nome LIKE '%Sassari%' OR ateneo_nome LIKE '%Enna%' OR ateneo_nome LIKE '%Reggio Calabria%' OR ateneo_nome LIKE '%Catanzaro%' OR ateneo_nome LIKE '%Cosenza%' OR ateneo_nome LIKE '%Lamezia%' OR ateneo_nome LIKE '%Vibo Valentia%' OR ateneo_nome LIKE '%Basilicata%' OR ateneo_nome LIKE '%Molise%' OR ateneo_nome LIKE '%L Aquila%' OR ateneo_nome LIKE '%Chieti%' OR ateneo_nome LIKE '%Pescara%' OR ateneo_nome LIKE '%Teramo%' OR ateneo_nome LIKE '%Loughborough%' THEN 'Isole-Mezzogiorno'
            ELSE 'Altro'
        END AS area_geografica
    FROM read_parquet('out/data/mart/mur_iscritti/*/mart_iscritti.parquet')
    WHERE anno = 2024
)
SELECT
    area_geografica,
    COUNT(DISTINCT ateneo_cod) AS n_atenei,
    SUM(totale) AS iscritti,
    ROUND(100.0 * SUM(totale) / (SELECT SUM(totale) FROM atenei_area), 1) AS pct_totale
FROM atenei_area
GROUP BY area_geografica
ORDER BY iscritti DESC
