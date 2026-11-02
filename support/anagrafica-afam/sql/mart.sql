SELECT
    cod_istituto,
    id_istituto,
    nome_istituto,
    tipo_istituto,
    tipo_sigla,
    cod_tipo_istituto,
    area_istituto,
    status,
    comune_sede,
    cap,
    indirizzo,
    cod_ripgeo,
    ripartizione,
    cod_reg_istat,
    regione,
    cod_prov_istat,
    provincia,
    web,
    stato_attivita,
    data_chiusura,
    annotazioni
FROM clean_input
ORDER BY cod_istituto
