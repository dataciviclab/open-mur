-- mart_contribuzione_trend.sql
-- DOMANDA: Come si finanzia il sistema universitario? Come cambia nel tempo?
-- Output: trend gettito per tipo, con variazione % annua

SELECT
    anno,
    descrizione_gettito,
    SUM(euro_contributo) AS totale_euro,
    ROUND(SUM(euro_contributo) / 1000000, 1) AS milioni,
    ROUND(100.0 * (SUM(euro_contributo) - LAG(SUM(euro_contributo)) OVER (
        PARTITION BY descrizione_gettito ORDER BY anno
    )) / NULLIF(LAG(SUM(euro_contributo)) OVER (
        PARTITION BY descrizione_gettito ORDER BY anno
    ), 0), 1) AS var_pct
FROM clean_input
GROUP BY anno, descrizione_gettito
ORDER BY descrizione_gettito, anno
