-- Q1: Historia wyjazdów karetki w danym miesiącu
SELECT
    k.nr_rejestracyjny,
    k.typ_karetki,
    w.id_wyjazdu,
    wez.data_zgloszenia,
    wez.priorytet,
    wez.adres,
    w.czas_wyjazdu,
    w.czas_powrotu,
    w.miejsce_docelowe
FROM wyjazdy w
JOIN karetki k 
ON w.id_karetki = k.id_karetki
JOIN wezwania wez
ON w.id_wezwania = wez.id_wezwania
WHERE k.nr_rejestracyjny = 'LDZ 1C005'
  AND EXTRACT(MONTH FROM w.czas_wyjazdu) = 1
  AND EXTRACT(YEAR  FROM w.czas_wyjazdu) = 2025
ORDER BY w.czas_wyjazdu;
