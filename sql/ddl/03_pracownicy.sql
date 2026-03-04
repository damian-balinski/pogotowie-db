CREATE TABLE pracownicy (
    id_pracownika  SERIAL PRIMARY KEY,
    imie           VARCHAR(50) NOT NULL,
    nazwisko       VARCHAR(50) NOT NULL,
    pesel          VARCHAR(11) NOT NULL UNIQUE,
    stanowisko     VARCHAR(50) NOT NULL
                   CHECK (stanowisko IN ('ratownik_medyczny', 'lekarz', 'kierowca')),
    nr_uprawnien   VARCHAR(30) UNIQUE
);
