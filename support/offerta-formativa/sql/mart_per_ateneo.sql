SELECT
    anno,
    ateneo_cod,
    ateneo,
    classe,
    nome_classe,
    COUNT(*) AS n_corsi,
    lingua
FROM clean_input
GROUP BY anno, ateneo_cod, ateneo, classe, nome_classe, lingua
