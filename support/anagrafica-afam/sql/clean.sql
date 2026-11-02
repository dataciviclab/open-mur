-- Clean: mur_afam_istituti
-- Anagrafica istituti AFAM (Accademie, Conservatori, ISIA, ...).
-- I codici ISTAT sono mantenuti come VARCHAR: il campo provincia della fonte
-- è a 2 cifre (es. "72" per Bari), non va troncato/interpretato come intero.

SELECT
    normalize_string(r."COD_ISTITUTO") AS cod_istituto,
    normalize_string(r."ID_ISTITUTO") AS id_istituto,
    COALESCE(
        normalize_string(r."NOME_ISTITUTO"),
        normalize_string(r."TIPO_ISTITUTO")
    ) AS nome_istituto,
    normalize_string(r."TIPO_ISTITUTO") AS tipo_istituto,
    normalize_string(r."TIPO_ISTITUTO_SIGLA") AS tipo_sigla,
    normalize_string(r."COD_TIPO_ISTITUTO") AS cod_tipo_istituto,
    normalize_string(r."Area_Istituto") AS area_istituto,
    normalize_string(r."STATUS") AS status,
    normalize_string(r."COMUNE_SEDE") AS comune_sede,
    normalize_string(r."CAP") AS cap,
    normalize_string(r."Indirizzo") AS indirizzo,
    normalize_string(r."COD_RIPGEO") AS cod_ripgeo,
    normalize_string(r."RIPGEO") AS ripartizione,
    normalize_string(r."COD_REG_ISTAT") AS cod_reg_istat,
    normalize_string(r."REGIONE_ISTITUTO") AS regione,
    normalize_string(r."COD_PROV_ISTAT") AS cod_prov_istat,
    normalize_string(r."PROVINCIA_ISTITUTO") AS provincia,
    normalize_string(r."web") AS web,
    normalize_string(r."Stato attività") AS stato_attivita,
    normalize_string(r."Data_Chiusura") AS data_chiusura,
    normalize_string(r."Annotazioni") AS annotazioni
FROM raw_input r
