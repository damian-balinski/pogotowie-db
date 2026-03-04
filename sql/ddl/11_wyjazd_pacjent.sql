CREATE TABLE wyjazd_pacjent (
    id                    SERIAL PRIMARY KEY,
    id_wyjazdu            INTEGER NOT NULL REFERENCES wyjazdy(id_wyjazdu),
    id_pacjenta           INTEGER NOT NULL REFERENCES pacjenci(id_pacjenta),
    stan_przy_przyjeciu   TEXT,
    stan_przy_przekazaniu TEXT,
    miejsce_przekazania   VARCHAR(200),
    UNIQUE (id_wyjazdu, id_pacjenta)
);

CREATE INDEX idx_wp_wyjazd  ON wyjazd_pacjent(id_wyjazdu);
CREATE INDEX idx_wp_pacjent ON wyjazd_pacjent(id_pacjenta);
