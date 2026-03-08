
-- Widok 3: Obciążenie dyspozytorni
-- Użycie: raporty zarządcze, planowanie zmian


CREATE OR REPLACE VIEW v_obciazenie_dyspozytorni AS
SELECT
    CONCAT(d.imie, ' ', d.nazwisko)     AS dyspozytor,
    TO_CHAR(wez.data_zgloszenia, 'YYYY-MM') AS miesiac,
    COUNT(wez.id_wezwania)          AS liczba_zgloszen,
    COUNT(CASE WHEN wez.priorytet = 'P1' THEN 1 END) AS p1,
    COUNT(CASE WHEN wez.priorytet = 'P2' THEN 1 END) AS p2,
    COUNT(CASE WHEN wez.priorytet = 'P3' THEN 1 END) AS p3,
    COUNT(CASE WHEN wez.status = 'ZAKONCZONE' THEN 1 END) AS zakonczone
FROM dyspozytorzy d
LEFT JOIN wezwania wez ON d.id_dyspozytora = wez.id_dyspozytora
GROUP BY d.id_dyspozytora, d.imie, d.nazwisko,
         TO_CHAR(wez.data_zgloszenia, 'YYYY-MM');
         

