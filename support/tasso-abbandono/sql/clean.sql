SELECT
    CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) AS anno_accademico,
    CAST("AnnoA" AS VARCHAR) AS anno_accademico_full,
    CAST(REPLACE("TA_M", ',', '.') AS DOUBLE) AS tasso_m,
    CAST(REPLACE("TA_F", ',', '.') AS DOUBLE) AS tasso_f,
    CAST(REPLACE("TA_TOT", ',', '.') AS DOUBLE) AS tasso_totale,
    CAST("Note" AS VARCHAR) AS note
FROM raw_input
WHERE TRY_CAST(SPLIT_PART("AnnoA", '/', 1) AS INTEGER) IS NOT NULL
