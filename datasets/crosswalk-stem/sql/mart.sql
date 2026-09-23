SELECT
    classe,
    tipo_corso,
    desc_classe,
    isced_1dgt,
    desc_isced_1dgt,
    isced_2dgt,
    desc_isced_2dgt,
    isced_3dgt,
    desc_isced_3dgt,
    area_stem
FROM clean_input
ORDER BY classe
