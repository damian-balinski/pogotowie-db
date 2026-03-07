-- Q6: Wyjazdy bez przypisanego pacjenta
SELECT
    w.id_wyjazdu,
    wez.data_zgloszenia,
    wez.adres,
    wez.priorytet,
    wez.opis_zdarzenia,
    k.nr_rejestracyjny,
    w.czas_wyjazdu,
    w.uwagi
FROM wyjazdy w
JOIN wezwania wez        ON w.id_wezwania = wez.id_wezwania
JOIN karetki k           ON w.id_karetki  = k.id_karetki
LEFT JOIN wyjazd_pacjent wp ON w.id_wyjazdu  = wp.id_wyjazdu
WHERE wp.id_wyjazdu IS NULL
ORDER BY w.czas_wyjazdu;

