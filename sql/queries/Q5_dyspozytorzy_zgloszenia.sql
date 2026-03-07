-- Q5: Dyspozytorzy z liczbą przyjętych zgłoszeń
SELECT
    CONCAT(d.imie, ' ', d.nazwisko)     AS dyspozytor,
    d.email,
    COUNT(wez.id_wezwania)          AS liczba_zgloszen,
    COUNT(CASE WHEN wez.priorytet = 'P1' THEN 1 END) AS zgloszenia_P1,
    COUNT(CASE WHEN wez.priorytet = 'P2' THEN 1 END) AS zgloszenia_P2,
    COUNT(CASE WHEN wez.priorytet = 'P3' THEN 1 END) AS zgloszenia_P3
FROM dyspozytorzy d
LEFT JOIN wezwania wez 
    ON d.id_dyspozytora = wez.id_dyspozytora
GROUP BY d.id_dyspozytora, d.imie, d.nazwisko, d.email
ORDER BY liczba_zgloszen DESC;
