WITH laureati_voto_raw AS (
    SELECT
        CAST("ANNO" AS INTEGER) AS anno,
        CAST("AteneoCOD" AS VARCHAR) AS cod_ateneo,
        CAST("AteneoNOME" AS VARCHAR) AS nome_ateneo,
        CAST("AteneoREGIONE" AS VARCHAR) AS regione,
        CAST("AteneoAREAGEO" AS VARCHAR) AS area_geo,
        CAST("Classe_Voto_Laurea" AS VARCHAR) AS classe_voto,
        CAST("Genere" AS VARCHAR) AS genere,
        TRY_CAST("LAU" AS INTEGER) AS laureati
    FROM raw_input
    WHERE
        TRY_CAST("ANNO" AS INTEGER) IS NOT NULL
        AND TRY_CAST("LAU" AS INTEGER) IS NOT NULL
        AND "LAU" >= 0
        AND "AteneoCOD" != 'TTTTT'
),
anagrafica AS (
    SELECT cod_ateneo, macro_area
    FROM read_parquet('{support.mur_anagrafica_atenei.mart}')
)
SELECT
    l.anno,
    l.cod_ateneo,
    l.nome_ateneo,
    l.regione,
    l.area_geo,
    COALESCE(a.macro_area, l.area_geo) AS macro_area,
    l.classe_voto,
    l.genere,
    l.laureati
FROM laureati_voto_raw l
LEFT JOIN anagrafica a ON l.cod_ateneo = a.cod_ateneo
