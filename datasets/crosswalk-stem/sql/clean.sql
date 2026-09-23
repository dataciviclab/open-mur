SELECT
    CAST("Classe" AS VARCHAR) AS classe,
    CAST("CorsoTIPO" AS VARCHAR) AS tipo_corso,
    CAST("DESC_CLASSE" AS VARCHAR) AS desc_classe,
    CAST("ISCED_F_1dgt" AS VARCHAR) AS isced_1dgt,
    CAST("DESC_ISCED_F_1dgt" AS VARCHAR) AS desc_isced_1dgt,
    CAST("ISCED_F_2dgt" AS VARCHAR) AS isced_2dgt,
    CAST("DESC_ISCED_F_2dgt" AS VARCHAR) AS desc_isced_2dgt,
    CAST("ISCED_F_3dgt" AS VARCHAR) AS isced_3dgt,
    CAST("DESC_ISCED_F_3dgt" AS VARCHAR) AS desc_isced_3dgt,
    CAST("Area STEM" AS VARCHAR) AS area_stem
FROM raw_input
