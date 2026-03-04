CREATE TABLE sklad_zespolu (
    id             SERIAL PRIMARY KEY,
    id_zespolu     INTEGER     NOT NULL REFERENCES zespoly(id_zespolu),
    id_pracownika  INTEGER     NOT NULL REFERENCES pracownicy(id_pracownika),
    rola_w_zespole VARCHAR(50) NOT NULL,
    UNIQUE (id_zespolu, id_pracownika)
);

CREATE INDEX idx_sklad_zespolu_zespol    ON sklad_zespolu(id_zespolu);
CREATE INDEX idx_sklad_zespolu_pracownik ON sklad_zespolu(id_pracownika);
