-- Q4: Liczba wezwań wg priorytetu i miesiąca
WITH wezwania_miesiac AS (
    SELECT
        TO_CHAR(data_zgloszenia, 'YYYY-MM') AS miesiac,
        priorytet
    FROM wezwania
)
SELECT
    miesiac,
    priorytet,
    COUNT(*) AS liczba_wezwan
FROM wezwania_miesiac
GROUP BY miesiac, priorytet
ORDER BY miesiac, priorytet;