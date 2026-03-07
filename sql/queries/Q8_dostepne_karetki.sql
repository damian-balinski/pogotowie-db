-- Q8: Aktualnie dostępne karetki (nie na wyjeździe)
SELECT
    k.id_karetki,
    k.nr_rejestracyjny,
    k.typ_karetki,
    k.rok_produkcji,
    k.status
FROM karetki k
WHERE k.status = 'DOSTEPNA'
  AND k.id_karetki NOT IN (
      SELECT w.id_karetki
      FROM wyjazdy w
      WHERE w.czas_powrotu IS NULL   -- wyjazd trwa, karetka nie wróciła
  )
ORDER BY k.id_karetki;
