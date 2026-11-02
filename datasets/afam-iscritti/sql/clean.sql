-- Clean: mur_afam_iscritti
-- Tre serie storiche (2010-2014, 2015-2019, 2020-2025) unite per nome.
-- Le serie più recenti usano SCUOLA, le precedenti SCUOLA_AGGREGAZIONE:
-- normalizzate in un'unica colonna `scuola`.

WITH iscritti_raw AS (
    SELECT
        cast_int(SPLIT_PART(r."ANNO_ACCADEMICO", '-', 1)) AS anno_accademico,
        normalize_string(r."COD_ISTITUTO") AS cod_istituto,
        normalize_string(r."NOME_ISTITUTO") AS nome_istituto,
        normalize_string(r."TIPO_ISTITUTO") AS tipo_istituto,
        normalize_string(r."Area_Istituto") AS area_istituto,
        normalize_string(r."COMUNE_SEDE") AS comune_sede,
        normalize_string(r."REGIONE_ISTITUTO") AS regione,
        normalize_string(r."AREA_CORSO") AS area_corso,
        normalize_string(r."TIPO_CORSO") AS tipo_corso,
        COALESCE(
            normalize_string(r."SCUOLA"),
            normalize_string(r."SCUOLA_AGGREGAZIONE")
        ) AS scuola,
        normalize_string(r."CLASSE") AS classe,
        normalize_string(r."CORSO") AS corso,
        normalize_string(r."GENERE") AS genere,
        cast_int(r."ISCRITTI") AS iscritti
    FROM raw_input r
    WHERE cast_int(r."ISCRITTI") IS NOT NULL
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
