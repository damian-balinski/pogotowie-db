CREATE TABLE katalog_swiadczen (
    id_swiadczenia  SERIAL PRIMARY KEY,
    kod_procedury   VARCHAR(20)  NOT NULL UNIQUE,
    nazwa           VARCHAR(200) NOT NULL,
    kategoria       VARCHAR(100),
    opis            TEXT
);
