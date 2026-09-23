WITH laureati_raw AS (
    SELECT
        CAST("AnnoS" AS INTEGER) AS anno,
        CAST("AteneoCOD" AS VARCHAR) AS ateneo_cod,
        CAST("AteneoNOME" AS VARCHAR) AS ateneo_nome,
        CAST("SESSO" AS VARCHAR) AS sesso,
        TRY_CAST("Lau" AS INTEGER) AS laureati
    FROM raw_input
    WHERE
        TRY_CAST("AnnoS" AS INTEGER) IS NOT NULL
        AND TRY_CAST("Lau" AS INTEGER) IS NOT NULL
        AND "Lau" >= 0
),
anagrafica AS (
    SELECT cod_ateneo, nome_operativo, macro_area, provincia, regione
    FROM read_parquet('{support.mur_anagrafica_atenei.mart}')
)
SELECT
    l.anno,
    l.ateneo_cod,
    l.ateneo_nome,
    l.sesso,
    l.laureati,
    COALESCE(a.macro_area, 'N/A') AS macro_area,
    COALESCE(a.provincia, 'N/A') AS provincia,
    COALESCE(a.regione, 'N/A') AS regione
FROM laureati_raw l
LEFT JOIN anagrafica a ON l.ateneo_cod = a.cod_ateneo
