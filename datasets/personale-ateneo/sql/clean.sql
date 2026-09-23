WITH personale_raw AS (
    SELECT
        CAST("ANNO" AS INTEGER) AS anno,
        CAST("CODICE_ATENEO" AS VARCHAR) AS cod_ateneo,
        CAST("NOME_ATENEO" AS VARCHAR) AS nome_ateneo,
        CAST("REGIONE" AS VARCHAR) AS regione,
        CAST("AREA_GEO" AS VARCHAR) AS area_geo,
        CAST("GRADE" AS VARCHAR) AS grade,
        CAST("GENERE" AS VARCHAR) AS genere,
        CAST("CLASSE_ETA'" AS VARCHAR) AS classe_eta,
        TRY_CAST("N_AcStaff" AS INTEGER) AS numero
    FROM raw_input
    WHERE
        TRY_CAST("ANNO" AS INTEGER) IS NOT NULL
        AND TRY_CAST("N_AcStaff" AS INTEGER) IS NOT NULL
        AND "N_AcStaff" >= 0
        AND "CODICE_ATENEO" != 'TTTTT'
),
anagrafica AS (
    SELECT cod_ateneo, macro_area
    FROM read_parquet('{support.mur_anagrafica_atenei.mart}')
)
SELECT
    p.anno,
    p.cod_ateneo,
    p.nome_ateneo,
    p.regione,
    p.area_geo,
    COALESCE(a.macro_area, p.area_geo) AS macro_area,
    p.grade,
    p.genere,
    p.classe_eta,
    p.numero
FROM personale_raw p
LEFT JOIN anagrafica a ON p.cod_ateneo = a.cod_ateneo
