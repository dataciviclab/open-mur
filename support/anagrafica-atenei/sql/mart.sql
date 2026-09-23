SELECT
    cod_ateneo,
    nome_esteso,
    nome_operativo,
    status,
    descrizione,
    tipo,
    citta,
    provincia,
    regione,
    macro_area
FROM clean_input
ORDER BY cod_ateneo
