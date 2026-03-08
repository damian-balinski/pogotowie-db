
-- TRIGGER T1: Automatyczna zmiana statusu karetki
-- Tabela zdarzenia: wyjazdy
-- Opis:
--  po dodaniu wyjazdu karetka staje się W_TRASIE
--  po uzupełnieniu czasu powrotu karetka staje się DOSTEPNA


DROP TRIGGER IF EXISTS trg_status_karetki ON wyjazdy;


-- Funkcja triggera

CREATE OR REPLACE FUNCTION fn_aktualizuj_status_karetki()
RETURNS TRIGGER AS $$
BEGIN

    -- NOWY WYJAZD -> karetka w trasie
    IF TG_OP = 'INSERT' THEN
        UPDATE karetki
        SET status = 'W_TRASIE'
        WHERE id_karetki = NEW.id_karetki;

    -- POWRÓT KARETKI
    ELSIF TG_OP = 'UPDATE'
       AND NEW.czas_powrotu IS NOT NULL
       AND OLD.czas_powrotu IS NULL THEN

        UPDATE karetki
        SET status = 'DOSTEPNA'
        WHERE id_karetki = NEW.id_karetki;

    END IF;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;



-- Definicja triggera

CREATE TRIGGER trg_status_karetki
AFTER INSERT OR UPDATE ON wyjazdy
FOR EACH ROW
EXECUTE FUNCTION fn_aktualizuj_status_karetki();