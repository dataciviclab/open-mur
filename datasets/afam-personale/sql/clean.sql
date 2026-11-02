-- Clean: mur_afam_personale
-- Due fonti (docente, ATA) unite con inject_column `tipo_personale`.
-- Le due fonti hanno misure e qualifiche diverse:
--   docente -> TIPOLOGIA_CONTRATTUALE + PERS_DOCENTE
--   ATA     -> QUALIFICA + PERSONALE_TA
-- Normalizzate in `qualifica` e `numero`.

WITH personale_raw AS (
    SELECT
        cast_int(SPLIT_PART(r."ANNO_ACCADEMICO", '-', 1)) AS anno_accademico,
        normalize_string(r."COD_ISTITUTO") AS cod_istituto,
        normalize_string(r."NOME_ISTITUTO") AS nome_istituto,
        normalize_string(r."TIPO_ISTITUTO") AS tipo_istituto,
        normalize_string(r."AREA_ISTITUTO") AS area_istituto,
        normalize_string(r."COMUNE_SEDE") AS comune_sede,
        normalize_string(r."REGIONE_ISTITUTO") AS regione,
        normalize_string(tipo_personale) AS tipo_personale,
        COALESCE(
            normalize_string(r."TIPOLOGIA_CONTRATTUALE"),
            normalize_string(r."QUALIFICA")
        ) AS qualifica,
        normalize_string(r."GENERE") AS genere,
        COALESCE(
            cast_int(r."PERS_DOCENTE"),
            cast_int(r."PERSONALE_TA")
        ) AS numero
    FROM raw_input r
    WHERE COALESCE(
        cast_int(r."PERS_DOCENTE"),
        cast_int(r."PERSONALE_TA")
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
