

REVOKE CREATE ON SCHEMA public FROM PUBLIC;



-- ROLA: dyspozytor
-- Może: czytać dane operacyjne + tworzyć nowe wezwania
-- Nie może: modyfikować danych medycznych, pacjentów, wyjazdów

DROP OWNED BY dyspozytor;
DROP ROLE IF EXISTS dyspozytor;

CREATE ROLE dyspozytor
    LOGIN
    PASSWORD 'dyspozytor'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

-- Połączenie z bazą
GRANT CONNECT ON DATABASE pogotowie_db TO dyspozytor;

-- Dostęp do schematu (wymagane w PostgreSQL 15+)
GRANT USAGE ON SCHEMA public TO dyspozytor;

-- Odczyt wszystkich tabel i widoków w schemacie public
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dyspozytor;

-- Automatyczny SELECT dla tabel tworzonych w przyszłości
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO dyspozytor;

-- Może tworzyć nowe wezwania
GRANT INSERT ON wezwania TO dyspozytor;

-- Sekwencja potrzebna do generowania id_wezwania przy INSERT
GRANT USAGE ON SEQUENCE wezwania_id_wezwania_seq TO dyspozytor;

-- Może aktualizować wyłącznie status wezwania (nie inne kolumny)
GRANT UPDATE (status) ON wezwania TO dyspozytor;

-- Może tworzyć wpis wyjazdu (przypisanie karetki i zespołu)
GRANT INSERT ON wyjazdy TO dyspozytor;

-- Sekwencja potrzebna do INSERT w wyjazdy
GRANT USAGE ON SEQUENCE wyjazdy_id_wyjazdu_seq TO dyspozytor;

-- Może aktualizować wyłącznie kolumny przypisania w wyjazdy
GRANT UPDATE (id_karetki, id_zespolu) ON wyjazdy TO dyspozytor;



-- ROLA: ratownik (ratownik medyczny / lekarz w karetce (tablet))
-- Może: czytać dane + uzupełniać wyjazdy i świadczenia
-- Nie może: usuwać danych ani zarządzać użytkownikami

DROP OWNED BY ratownik;
DROP ROLE IF EXISTS ratownik;

CREATE ROLE ratownik
    LOGIN
    PASSWORD 'ratownik'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE;

-- Połączenie z bazą
GRANT CONNECT ON DATABASE pogotowie_db TO ratownik;

-- Dostęp do schematu
GRANT USAGE ON SCHEMA public TO ratownik;

-- Odczyt wszystkich tabel i widoków w schemacie public
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ratownik;

-- Automatyczny SELECT dla tabel tworzonych w przyszłości
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO ratownik;

-- Rejestrowanie wyjazdów
GRANT INSERT, UPDATE ON wyjazdy TO ratownik;

-- Rejestracja i aktualizacja danych pacjentów
GRANT INSERT, UPDATE ON pacjenci TO ratownik;

-- Powiązanie pacjenta z wyjazdem
GRANT INSERT, UPDATE ON wyjazd_pacjent TO ratownik;

-- Wpisywanie udzielonej pomocy medycznej
GRANT INSERT, UPDATE ON udzielona_pomoc TO ratownik;

-- Sekwencje potrzebne do INSERT 
GRANT USAGE ON SEQUENCE wyjazdy_id_wyjazdu_seq     TO ratownik;
GRANT USAGE ON SEQUENCE pacjenci_id_pacjenta_seq   TO ratownik;
GRANT USAGE ON SEQUENCE wyjazd_pacjent_id_seq      TO ratownik;
GRANT USAGE ON SEQUENCE udzielona_pomoc_id_seq     TO ratownik;


-- ROLA: admin_pogotowie
-- Może: pełna administracja bazą i użytkownikami
-- SUPERUSER omija wszystkie kontrole uprawnień

DROP OWNED BY admin_pogotowie;
DROP ROLE IF EXISTS admin_pogotowie;

CREATE ROLE admin_pogotowie
    LOGIN
    PASSWORD 'AdminPogotowie'
    SUPERUSER
    CREATEDB
    CREATEROLE;


-- Zapytanie weryfikacyjne 

SELECT
    rolname              AS rola,
    rolsuper             AS superuser,
    rolcreatedb          AS moze_tworzyc_bazy,
    rolcreaterole        AS moze_tworzyc_role,
    rolcanlogin          AS moze_sie_logowac,
    rolconnlimit         AS limit_polaczen
FROM pg_roles
WHERE rolname IN ('dyspozytor', 'ratownik', 'admin_pogotowie')
ORDER BY rolname;