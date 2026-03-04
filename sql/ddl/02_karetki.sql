CREATE TABLE karetki (
    id_karetki        SERIAL PRIMARY KEY,
    nr_rejestracyjny  VARCHAR(10)  NOT NULL UNIQUE,
    typ_karetki       VARCHAR(1)   NOT NULL CHECK (typ_karetki IN ('P', 'S', 'R')),
    rok_produkcji     INTEGER      CHECK (rok_produkcji BETWEEN 1990 AND 2030),
    status            VARCHAR(15)  NOT NULL DEFAULT 'DOSTEPNA'
                                   CHECK (status IN ('DOSTEPNA', 'W_TRASIE', 'W_SERWISIE'))
);
