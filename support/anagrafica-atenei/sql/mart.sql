SELECT
    cod_ateneo,
    nome_esteso,
    nome_operativo,
    status,
    descrizione,
    tipo,
    citta,
    provincia,
    sigla_provincia,
    cod_provincia_istat,
    regione,
    macro_area
FROM clean_input
ORDER BY cod_ateneo
