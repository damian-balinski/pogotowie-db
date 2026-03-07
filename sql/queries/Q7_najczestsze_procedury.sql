-- Q7: Najczęściej stosowane procedury medyczne
SELECT
    ks.kod_procedury,
    ks.nazwa                    AS procedura,
    ks.kategoria,
    COUNT(up.id)                AS liczba_wykonan,
    ROUND(COUNT(up.id) * 100.0 /
          SUM(COUNT(up.id)) OVER (), 1) AS procent_udzialu
FROM katalog_swiadczen ks
LEFT JOIN udzielona_pomoc up 
    ON ks.id_swiadczenia = up.id_swiadczenia
GROUP BY ks.id_swiadczenia, ks.kod_procedury, ks.nazwa, ks.kategoria
ORDER BY liczba_wykonan DESC;
