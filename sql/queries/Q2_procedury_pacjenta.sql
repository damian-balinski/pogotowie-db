-- Q2: Procedury udzielone pacjentowi po PESEL
SELECT
    CONCAT(p.imie, ' ', p.nazwisko) AS pacjent,
    p.pesel,
    wez.data_zgloszenia,
    wez.adres                       AS miejsce_zdarzenia,
    ks.kod_procedury,
    ks.nazwa                        AS procedura,
    ks.kategoria,
    up.godzina_wykonania,
    up.wynik,
    up.uwagi
FROM udzielona_pomoc up
JOIN pacjenci p
    ON up.id_pacjenta = p.id_pacjenta
JOIN katalog_swiadczen ks
    ON up.id_swiadczenia = ks.id_swiadczenia
JOIN wyjazdy wyj
    ON up.id_wyjazdu = wyj.id_wyjazdu
JOIN wezwania wez
    ON wyj.id_wezwania = wez.id_wezwania
WHERE p.pesel = '59010198765'
ORDER BY up.godzina_wykonania;
