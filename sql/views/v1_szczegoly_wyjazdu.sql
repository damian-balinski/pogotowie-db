
-- Widok 1: Pełne zestawienie wyjazdu
-- Łączy: wyjazdy, wezwania, karetki, zespoly, dyspozytorzy
-- Użycie: raporty operacyjne, przegląd historii wyjazdów

CREATE OR REPLACE VIEW v_szczegoly_wyjazdu AS
SELECT
    w.id_wyjazdu,
    -- dane zgłoszenia
    wez.id_wezwania,
    wez.data_zgloszenia,
    wez.godzina_zgloszenia,
    wez.adres               AS adres_zdarzenia,
    wez.miasto,
    wez.priorytet,
    wez.opis_zdarzenia,
    wez.status              AS status_wezwania,
    -- dyspozytor który przyjął zgłoszenie
    CONCAT(d.imie, ' ', d.nazwisko)     AS dyspozytor,
    -- karetka
    k.nr_rejestracyjny,
    k.typ_karetki,
    -- zespół
    z.nazwa_zespolu,
    z.typ_zespolu           AS typ_zespolu,
    -- czasy wyjazdu
    w.czas_wyjazdu,
    w.czas_przybycia,
    w.czas_powrotu,
    -- obliczony czas interwencji w minutach
    CASE
    WHEN w.czas_powrotu IS NOT NULL
    THEN ROUND(EXTRACT(EPOCH FROM (w.czas_powrotu - w.czas_wyjazdu)) / 60)
    END AS czas_interwencji_min,
    w.miejsce_docelowe,
    w.uwagi
FROM wyjazdy w
JOIN wezwania     wez ON w.id_wezwania  = wez.id_wezwania
JOIN karetki      k   ON w.id_karetki   = k.id_karetki
JOIN zespoly      z   ON w.id_zespolu   = z.id_zespolu
JOIN dyspozytorzy d   ON wez.id_dyspozytora = d.id_dyspozytora;


