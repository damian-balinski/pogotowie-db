CREATE TABLE zmiany (
    id_zmiany      SERIAL PRIMARY KEY,
    data_zmiany    DATE        NOT NULL,
    godzina_start  TIME        NOT NULL,
    godzina_koniec TIME        NOT NULL,
    typ_zmiany     VARCHAR(20) NOT NULL CHECK (typ_zmiany IN ('dzienna', 'nocna'))
);
