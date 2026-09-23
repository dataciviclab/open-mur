SELECT
    anno_accademico,
    anno_accademico_full,
    tasso_m,
    tasso_f,
    tasso_totale,
    ROUND(tasso_m - tasso_f, 1) AS gap_genere,
    note
FROM clean_input
ORDER BY anno_accademico
