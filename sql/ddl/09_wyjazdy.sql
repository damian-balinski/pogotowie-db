CREATE TABLE wyjazdy (
    id_wyjazdu       SERIAL PRIMARY KEY,
    id_wezwania      INTEGER      NOT NULL REFERENCES wezwania(id_wezwania),
    id_karetki       INTEGER      NOT NULL REFERENCES karetki(id_karetki),
    id_zespolu       INTEGER      NOT NULL REFERENCES zespoly(id_zespolu),
    czas_wyjazdu     TIMESTAMP    NOT NULL,
    czas_przybycia   TIMESTAMP,
    czas_powrotu     TIMESTAMP,
    miejsce_docelowe VARCHAR(200),
    uwagi            TEXT
);

CREATE INDEX idx_wyjazdy_wezwanie ON wyjazdy(id_wezwania);
CREATE INDEX idx_wyjazdy_karetka  ON wyjazdy(id_karetki);
CREATE INDEX idx_wyjazdy_zespol   ON wyjazdy(id_zespolu);
