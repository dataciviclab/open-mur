-- Clean: mur_afam_istituti
-- Anagrafica istituti AFAM (Accademie, Conservatori, ISIA, ...).
-- I codici ISTAT sono mantenuti come VARCHAR: il campo provincia della fonte
-- è a 2 cifre (es. "72" per Bari), non va troncato/interpretato come intero.

SELECT
    CAST(r."COD_ISTITUTO" AS VARCHAR) AS cod_istituto,
    CAST(r."ID_ISTITUTO" AS VARCHAR) AS id_istituto,
    COALESCE(
        NULLIF(TRIM(CAST(r."NOME_ISTITUTO" AS VARCHAR)), ''),
        CAST(r."TIPO_ISTITUTO" AS VARCHAR)
    ) AS nome_istituto,
    CAST(r."TIPO_ISTITUTO" AS VARCHAR) AS tipo_istituto,
    CAST(r."TIPO_ISTITUTO_SIGLA" AS VARCHAR) AS tipo_sigla,
    CAST(r."COD_TIPO_ISTITUTO" AS VARCHAR) AS cod_tipo_istituto,
    CAST(r."Area_Istituto" AS VARCHAR) AS area_istituto,
    CAST(r."STATUS" AS VARCHAR) AS status,
    CAST(r."COMUNE_SEDE" AS VARCHAR) AS comune_sede,
    CAST(r."CAP" AS VARCHAR) AS cap,
    CAST(r."Indirizzo" AS VARCHAR) AS indirizzo,
    CAST(r."COD_RIPGEO" AS VARCHAR) AS cod_ripgeo,
    CAST(r."RIPGEO" AS VARCHAR) AS ripartizione,
    CAST(r."COD_REG_ISTAT" AS VARCHAR) AS cod_reg_istat,
    CAST(r."REGIONE_ISTITUTO" AS VARCHAR) AS regione,
    CAST(r."COD_PROV_ISTAT" AS VARCHAR) AS cod_prov_istat,
    CAST(r."PROVINCIA_ISTITUTO" AS VARCHAR) AS provincia,
    CAST(r."web" AS VARCHAR) AS web,
    CAST(r."Stato attività" AS VARCHAR) AS stato_attivita,
    CAST(r."Data_Chiusura" AS VARCHAR) AS data_chiusura,
    CAST(r."Annotazioni" AS VARCHAR) AS annotazioni
FROM raw_input r
