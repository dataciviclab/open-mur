-- Clean: mur_afam_iscritti
-- Tre serie storiche (2010-2014, 2015-2019, 2020-2025) unite per nome.
-- Le serie più recenti usano SCUOLA, le precedenti SCUOLA_AGGREGAZIONE:
-- normalizzate in un'unica colonna `scuola`.

WITH iscritti_raw AS (
    SELECT
        CAST(SPLIT_PART("ANNO_ACCADEMICO", '-', 1) AS INTEGER) AS anno_accademico,
        CAST("COD_ISTITUTO" AS VARCHAR) AS cod_istituto,
        CAST("NOME_ISTITUTO" AS VARCHAR) AS nome_istituto,
        CAST("TIPO_ISTITUTO" AS VARCHAR) AS tipo_istituto,
        CAST("Area_Istituto" AS VARCHAR) AS area_istituto,
        CAST("COMUNE_SEDE" AS VARCHAR) AS comune_sede,
        CAST("REGIONE_ISTITUTO" AS VARCHAR) AS regione,
        CAST("AREA_CORSO" AS VARCHAR) AS area_corso,
        CAST("TIPO_CORSO" AS VARCHAR) AS tipo_corso,
        COALESCE(
            NULLIF(TRIM(CAST("SCUOLA" AS VARCHAR)), ''),
            CAST("SCUOLA_AGGREGAZIONE" AS VARCHAR)
        ) AS scuola,
        CAST("CLASSE" AS VARCHAR) AS classe,
        CAST("CORSO" AS VARCHAR) AS corso,
        CAST("GENERE" AS VARCHAR) AS genere,
        TRY_CAST("ISCRITTI" AS INTEGER) AS iscritti
    FROM raw_input
    WHERE TRY_CAST("ISCRITTI" AS INTEGER) IS NOT NULL
),
-- cod_istituto non è univoco nella fonte (6 codici con più sedi): una riga per
-- codice evita il fan-out nel join. La provincia scelta è la min alfabetica,
-- che nei dati attuali coincide con la sede principale.
anagrafica AS (
    SELECT
        cod_istituto,
        MIN(cod_reg_istat) AS cod_reg_istat,
        MIN(regione) AS regione,
        MIN(provincia) AS provincia
    FROM read_parquet('{support.mur_afam_istituti.mart}')
    GROUP BY cod_istituto
)
SELECT
    r.anno_accademico,
    r.cod_istituto,
    r.nome_istituto,
    r.tipo_istituto,
    r.area_istituto,
    r.comune_sede,
    COALESCE(a.regione, r.regione, 'N/A') AS regione,
    COALESCE(a.cod_reg_istat, 'N/A') AS cod_reg_istat,
    COALESCE(a.provincia, 'N/A') AS provincia,
    r.area_corso,
    r.tipo_corso,
    r.scuola,
    r.classe,
    r.corso,
    r.genere,
    r.iscritti
FROM iscritti_raw r
LEFT JOIN anagrafica a ON r.cod_istituto = a.cod_istituto
