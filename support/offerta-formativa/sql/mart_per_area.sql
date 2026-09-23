SELECT
    anno,
    COUNT(DISTINCT ateneo_cod) AS n_atenei,
    COUNT(DISTINCT classe) AS n_classi,
    COUNT(*) AS n_corsi,
    COUNT(DISTINCT corso) AS n_corsi_distinti,
    SUM(CASE WHEN lingua = 'Inglese' THEN 1 ELSE 0 END) AS corsi_in_inglese,
    ROUND(100.0 * SUM(CASE WHEN lingua = 'Inglese' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_inglese
FROM clean_input
GROUP BY anno
ORDER BY anno
