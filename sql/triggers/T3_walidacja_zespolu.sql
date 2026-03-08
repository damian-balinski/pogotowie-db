-- Trigger 3: Walidacja minimalnego składu zespołu
-- Zdarzenie: BEFORE INSERT na tabeli wyjazdy

DROP TRIGGER IF EXISTS trg_walidacja_zespolu ON wyjazdy;

-- funkcja
CREATE OR REPLACE FUNCTION fn_waliduj_sklad_zespolu()
RETURNS TRIGGER AS $$
DECLARE
    v_liczba_czlonkow INTEGER;  -- zmienna przechowująca liczbę członków zespołu
BEGIN
    -- policz członków zespołu przypisanego do nowego wyjazdu
    SELECT COUNT(*) INTO v_liczba_czlonkow
    FROM sklad_zespolu
    WHERE id_zespolu = NEW.id_zespolu;

    -- jeśli mniej niż 2, przerwij INSERT i zgłoś błąd
    IF v_liczba_czlonkow < 2 THEN
        RAISE EXCEPTION
            'Zespół % ma tylko % członków. Wymagane minimum to 2.',
            NEW.id_zespolu, v_liczba_czlonkow;
    END IF;

    RETURN NEW;  -- pozwala na wykonanie INSERT jeśli warunek spełniony
END;
$$ LANGUAGE plpgsql;

-- trigger
CREATE OR REPLACE TRIGGER trg_walidacja_zespolu
BEFORE INSERT ON wyjazdy  -- trigger BEFORE, bo chcemy zatrzymać wstawienie, jeśli warunek nie spełniony
FOR EACH ROW
EXECUTE FUNCTION fn_waliduj_sklad_zespolu();