WITH post_laurea_raw AS (
    SELECT
        CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) AS anno_accademico,
        CAST("AteneoCOD" AS VARCHAR) AS ateneo_cod,
        CAST("AteneoNOME" AS VARCHAR) AS ateneo_nome,
        CAST("CorsoTIPO" AS VARCHAR) AS tipo_corso,
        CAST("Sesso" AS VARCHAR) AS sesso,
        TRY_CAST("Isc" AS INTEGER) AS iscritti,
        CAST(livello AS VARCHAR) AS livello
    FROM raw_input
    WHERE
        TRY_CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) IS NOT NULL
        AND TRY_CAST("Isc" AS INTEGER) IS NOT NULL
        AND "Isc" >= 0
),
anagrafica AS (
    SELECT cod_ateneo, nome_operativo, macro_area, regione
    FROM read_parquet('{support.mur_anagrafica_atenei.mart}')
)
SELECT
    p.anno_accademico,
    p.ateneo_cod,
    p.ateneo_nome,
    p.livello,
    p.tipo_corso,
    p.sesso,
    p.iscritti,
    COALESCE(a.macro_area, 'N/A') AS macro_area,
    COALESCE(a.regione, 'N/A') AS regione
FROM post_laurea_raw p
LEFT JOIN anagrafica a ON p.ateneo_cod = a.cod_ateneo
