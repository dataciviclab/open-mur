WITH iscritti_raw AS (
    SELECT
        CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) AS anno,
        CAST("AteneoCOD" AS VARCHAR) AS ateneo_cod,
        CAST("AteneoNOME" AS VARCHAR) AS ateneo_nome,
        CAST("SESSO" AS VARCHAR) AS sesso,
        TRY_CAST("Iscritti" AS INTEGER) AS iscritti
    FROM raw_input
    WHERE
        TRY_CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) IS NOT NULL
        AND TRY_CAST("Iscritti" AS INTEGER) IS NOT NULL
        AND "Iscritti" >= 0
),
anagrafica AS (
    SELECT cod_ateneo, nome_operativo, macro_area, provincia, regione
    FROM read_parquet('{support.mur_anagrafica_atenei.mart}')
)
SELECT
    i.anno,
    i.ateneo_cod,
    i.ateneo_nome,
    i.sesso,
    i.iscritti,
    COALESCE(a.macro_area, 'N/A') AS macro_area,
    COALESCE(a.provincia, 'N/A') AS provincia,
    COALESCE(a.regione, 'N/A') AS regione
FROM iscritti_raw i
LEFT JOIN anagrafica a ON i.ateneo_cod = a.cod_ateneo
