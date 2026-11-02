-- Clean: mur_esoneri
-- Due risorse per anno (esonero totale, esonero parziale), unite con inject_column.
-- ANNO_ACCADEMICO è "2024-2025": si tiene l'anno di inizio (2024).
-- COD_ATENEO è a 5 cifre ("00101"): normalizzato a intero per allinearlo
-- all'anagrafica atenei ("101").

WITH esoneri_raw AS (
    SELECT
        cast_int(SPLIT_PART(r."ANNO_ACCADEMICO", '-', 1)) AS anno_accademico,
        normalize_string(cast_int(r."COD_ATENEO")) AS cod_ateneo,
        normalize_string(r."NOME_ATENEO") AS nome_ateneo,
        normalize_string(r.tipo_esonero) AS tipo_esonero,
        COALESCE(
            normalize_string(r."CODICE_ESONERO_TOTALE"),
            normalize_string(r."CODICE_ESONERO_PARZIALE")
        ) AS codice_esonero,
        COALESCE(
            normalize_string(r."DESCRIZIONE_ESONERO_TOTALE"),
            normalize_string(r."DESCRIZIONE_ESONERO_PARZIALE")
        ) AS descrizione_esonero,
        COALESCE(cast_int(r."ESONERO_TOTALE_LAUREA"), cast_int(r."ESONERO_PARZIALE_LAUREA"), 0) AS laurea,
        COALESCE(cast_int(r."ESONERO_TOTALE_DOTTORATO"), cast_int(r."ESONERO_PARZIALE_DOTTORATO"), 0) AS dottorato,
        COALESCE(cast_int(r."ESONERO_TOTALE_SPECIALIZZAZIONE"), cast_int(r."ESONERO_PARZIALE_SPECIALIZZAZIONE"), 0) AS specializzazione,
        COALESCE(cast_int(r."ESONERO_TOTALE_MASTER"), cast_int(r."ESONERO_PARZIALE_MASTER"), 0) AS master
    FROM raw_input r
),
anagrafica AS (
    SELECT cod_ateneo, macro_area, regione
    FROM read_parquet('{support.mur_anagrafica_atenei.mart}')
)
SELECT
    e.anno_accademico,
    e.cod_ateneo,
    e.nome_ateneo,
    e.tipo_esonero,
    e.codice_esonero,
    e.descrizione_esonero,
    e.laurea,
    e.dottorato,
    e.specializzazione,
    e.master,
    e.laurea + e.dottorato + e.specializzazione + e.master AS totale,
    COALESCE(a.macro_area, 'N/A') AS macro_area,
    COALESCE(a.regione, 'N/A') AS regione
FROM esoneri_raw e
LEFT JOIN anagrafica a ON e.cod_ateneo = a.cod_ateneo
