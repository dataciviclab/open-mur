SELECT
    CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) AS anno,
    CAST("AteneoCOD" AS VARCHAR) AS ateneo_cod,
    CAST("AteneoNOME" AS VARCHAR) AS ateneo,
    CAST("ClasseNUMERO" AS VARCHAR) AS classe,
    CAST("ClasseNOME" AS VARCHAR) AS nome_classe,
    CAST("CorsoNOME" AS VARCHAR) AS corso,
    CAST("SedeC" AS VARCHAR) AS sede_comune,
    CAST("SedeP" AS VARCHAR) AS sede_provincia,
    CAST("CorsoLingua" AS VARCHAR) AS lingua
FROM raw_input
WHERE TRY_CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) IS NOT NULL
