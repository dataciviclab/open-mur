SELECT
    CAST("COD_Ateneo" AS VARCHAR) AS cod_ateneo,
    CAST("NomeEsteso" AS VARCHAR) AS nome_esteso,
    CAST("NomeOperativo" AS VARCHAR) AS nome_operativo,
    CAST("Status" AS VARCHAR) AS status,
    CAST("Descrizione" AS VARCHAR) AS descrizione,
    CAST("StataleLibera" AS VARCHAR) AS tipo,
    CAST("CITTA" AS VARCHAR) AS citta,
    CAST("PROVINCIA" AS VARCHAR) AS provincia,
    CAST("REGIONE" AS VARCHAR) AS regione,
    CAST("NOME_REGIONE_MACRO" AS VARCHAR) AS macro_area
FROM raw_input
