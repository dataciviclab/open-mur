-- Clean: mur_afam_personale
-- Due fonti (docente, ATA) unite con inject_column `tipo_personale`.
-- Le due fonti hanno misure e qualifiche diverse:
--   docente -> TIPOLOGIA_CONTRATTUALE + PERS_DOCENTE
--   ATA     -> QUALIFICA + PERSONALE_TA
-- Normalizzate in `qualifica` e `numero`.

WITH personale_raw AS (
    SELECT
        CAST(SPLIT_PART("ANNO_ACCADEMICO", '-', 1) AS INTEGER) AS anno_accademico,
        CAST("COD_ISTITUTO" AS VARCHAR) AS cod_istituto,
        CAST("NOME_ISTITUTO" AS VARCHAR) AS nome_istituto,
        CAST("TIPO_ISTITUTO" AS VARCHAR) AS tipo_istituto,
        CAST("AREA_ISTITUTO" AS VARCHAR) AS area_istituto,
        CAST("COMUNE_SEDE" AS VARCHAR) AS comune_sede,
        CAST("REGIONE_ISTITUTO" AS VARCHAR) AS regione,
        CAST(tipo_personale AS VARCHAR) AS tipo_personale,
        COALESCE(
            NULLIF(TRIM(CAST("TIPOLOGIA_CONTRATTUALE" AS VARCHAR)), ''),
            CAST("QUALIFICA" AS VARCHAR)
        ) AS qualifica,
        CAST("GENERE" AS VARCHAR) AS genere,
        COALESCE(
            TRY_CAST("PERS_DOCENTE" AS INTEGER),
            TRY_CAST("PERSONALE_TA" AS INTEGER)
        ) AS numero
    FROM raw_input
    WHERE COALESCE(
        TRY_CAST("PERS_DOCENTE" AS INTEGER),
        TRY_CAST("PERSONALE_TA" AS INTEGER)
    ) IS NOT NULL
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
    r.tipo_personale,
    r.qualifica,
    r.genere,
    r.numero
FROM personale_raw r
LEFT JOIN anagrafica a ON r.cod_istituto = a.cod_istituto
