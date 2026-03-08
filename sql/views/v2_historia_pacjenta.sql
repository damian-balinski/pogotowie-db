
-- Widok 2: Historia medyczna pacjenta
-- Łączy: pacjenci, udzielona_pomoc, katalog_swiadczen,
--        wyjazdy, wezwania
-- Użycie: dokumentacja medyczna, raport dla lekarzy w SOR


CREATE OR REPLACE VIEW v_historia_pacjenta AS
SELECT
    -- dane pacjenta
    p.id_pacjenta,
    CONCAT(p.imie, ' ', p.nazwisko)     AS pacjent,
    p.pesel,
    p.data_urodzenia,
    p.plec,
    -- zdarzenie
    wez.data_zgloszenia,
    wez.adres                       AS miejsce_zdarzenia,
    wez.priorytet,
    -- szczegóły wyjazdu i przekazania
    wp.stan_przy_przyjeciu,
    wp.stan_przy_przekazaniu,
    wp.miejsce_przekazania,
    -- procedura medyczna
    ks.kod_procedury,
    ks.nazwa                        AS procedura,
    ks.kategoria                    AS kategoria_procedury,
    up.godzina_wykonania,
    up.wynik,
    up.uwagi                        AS uwagi_procedury
FROM pacjenci p
JOIN udzielona_pomoc  up  ON p.id_pacjenta      = up.id_pacjenta
JOIN katalog_swiadczen ks  ON up.id_swiadczenia  = ks.id_swiadczenia
JOIN wyjazdy          wyj  ON up.id_wyjazdu      = wyj.id_wyjazdu
JOIN wezwania         wez  ON wyj.id_wezwania    = wez.id_wezwania
LEFT JOIN wyjazd_pacjent wp ON (wp.id_wyjazdu    = wyj.id_wyjazdu
                             AND wp.id_pacjenta   = p.id_pacjenta);

