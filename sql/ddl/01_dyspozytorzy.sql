CREATE TABLE dyspozytorzy (
    id_dyspozytora SERIAL PRIMARY KEY,
    imie           VARCHAR(50)  NOT NULL,
    nazwisko       VARCHAR(50)  NOT NULL,
    telefon        VARCHAR(15),
    email          VARCHAR(100) UNIQUE
);
