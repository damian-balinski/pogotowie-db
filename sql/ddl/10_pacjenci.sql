CREATE TABLE pacjenci (
    id_pacjenta   SERIAL PRIMARY KEY,
    imie          VARCHAR(50)  NOT NULL,
    nazwisko      VARCHAR(50)  NOT NULL,
    pesel         VARCHAR(11)  UNIQUE,
    data_urodzenia DATE,
    plec          VARCHAR(1)   CHECK (plec IN ('M', 'K', 'N')),
    nr_telefonu   VARCHAR(15),
    adres         VARCHAR(200)
);
