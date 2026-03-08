
-- Trigger 2: Logowanie zmian statusu wezwania
-- Zdarzenie: UPDATE na tabeli wezwania (tylko gdy zmienia się status)

DROP TRIGGER IF EXISTS trg_log_statusu_wezwania ON wezwania;

-- funkcja
CREATE OR REPLACE FUNCTION fn_loguj_zmiane_statusu()
RETURNS TRIGGER AS $$
BEGIN
    -- Reaguj TYLKO gdy status faktycznie się zmienił
    IF NEW.status <> OLD.status THEN
        INSERT INTO log_wezwan (id_wezwania, stary_status, nowy_status,
                                zmieniono_o, uzytkownik)
        VALUES (OLD.id_wezwania, OLD.status, NEW.status,
                NOW(), CURRENT_USER);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- trigger
CREATE OR REPLACE TRIGGER trg_log_statusu_wezwania
AFTER UPDATE ON wezwania
FOR EACH ROW
EXECUTE FUNCTION fn_loguj_zmiane_statusu();
