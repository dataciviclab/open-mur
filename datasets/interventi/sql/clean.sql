-- Clean: mur_interventi
-- Numero di interventi in favore degli studenti (borse di studio, sostegni).
-- ANNO_ACCADEMICO è "2024-2025": si tiene l'anno di inizio (2024).
-- COD_ATENEO è a 5 cifre ("00101"): normalizzato a intero per allinearlo
-- all'anagrafica atenei ("101").

WITH interventi_raw AS (
    SELECT
        cast_int(SPLIT_PART(r."ANNO_ACCADEMICO", '-', 1)) AS anno_accademico,
        normalize_string(cast_int(r."COD_ATENEO")) AS cod_ateneo,
        normalize_string(r."NOME_ATENEO") AS nome_ateneo,
        normalize_string(r."CODICE_INTERVENTO") AS codice_intervento,
        normalize_string(r."DESCRIZIONE_INTERVENTO") AS descrizione_intervento,
        COALESCE(cast_int(r."INTERVENTI_LAUREA"), 0) AS laurea,
        COALESCE(cast_int(r."INTERVENTI_LAUREA_EXTRA_UE"), 0) AS laurea_extra_ue,
        COALESCE(cast_int(r."INTERVENTI_DOTTORATO"), 0) AS dottorato,
        COALESCE(cast_int(r."INTERVENTI_SPECIALIZZAZIONE"), 0) AS specializzazione,
        COALESCE(cast_int(r."INTERVENTI_MASTER"), 0) AS master
    FROM raw_input r
),
anagrafica AS (
    SELECT cod_ateneo, macro_area, regione
    FROM read_parquet('{support.mur_anagrafica_atenei.mart}')
)
SELECT
    i.anno_accademico,
    i.cod_ateneo,
    i.nome_ateneo,
    i.codice_intervento,
    i.descrizione_intervento,
    i.laurea,
    i.laurea_extra_ue,
    i.dottorato,
    i.specializzazione,
    i.master,
    i.laurea + i.laurea_extra_ue + i.dottorato + i.specializzazione + i.master AS totale,
    COALESCE(a.macro_area, 'N/A') AS macro_area,
    COALESCE(a.regione, 'N/A') AS regione
FROM interventi_raw i
LEFT JOIN anagrafica a ON i.cod_ateneo = a.cod_ateneo
