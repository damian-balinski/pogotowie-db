-- Q3: Średni czas interwencji (wyjazd → powrót) w minutach
SELECT
    k.typ_karetki,
    COUNT(w.id_wyjazdu)                                          AS liczba_wyjazdow,
    ROUND(AVG(EXTRACT(EPOCH FROM (w.czas_powrotu - w.czas_wyjazdu)) / 60))
                                                                 AS sredni_czas_min,
    ROUND(MIN(EXTRACT(EPOCH FROM (w.czas_powrotu - w.czas_wyjazdu)) / 60))
                                                                 AS min_czas_min,
    ROUND(MAX(EXTRACT(EPOCH FROM (w.czas_powrotu - w.czas_wyjazdu)) / 60))
                                                                 AS max_czas_min
FROM wyjazdy w
JOIN karetki k ON w.id_karetki = k.id_karetki
WHERE w.czas_powrotu IS NOT NULL
GROUP BY k.typ_karetki
ORDER BY sredni_czas_min DESC;
