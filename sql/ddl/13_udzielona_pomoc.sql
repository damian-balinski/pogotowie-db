CREATE TABLE udzielona_pomoc (
    id              SERIAL PRIMARY KEY,
    id_wyjazdu      INTEGER   NOT NULL REFERENCES wyjazdy(id_wyjazdu),
    id_pacjenta     INTEGER   NOT NULL REFERENCES pacjenci(id_pacjenta),
    id_swiadczenia  INTEGER   NOT NULL REFERENCES katalog_swiadczen(id_swiadczenia),
    godzina_wykonania TIMESTAMP,
    wynik           VARCHAR(100),
    uwagi           TEXT
);

CREATE INDEX idx_up_wyjazd     ON udzielona_pomoc(id_wyjazdu);
CREATE INDEX idx_up_pacjent    ON udzielona_pomoc(id_pacjenta);
CREATE INDEX idx_up_swiadczenie ON udzielona_pomoc(id_swiadczenia);
