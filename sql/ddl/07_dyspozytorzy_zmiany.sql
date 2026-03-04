CREATE TABLE dyspozytorzy_zmiany (
    id              SERIAL  PRIMARY KEY,
    id_dyspozytora  INTEGER NOT NULL REFERENCES dyspozytorzy(id_dyspozytora),
    id_zmiany       INTEGER NOT NULL REFERENCES zmiany(id_zmiany),
    UNIQUE (id_dyspozytora, id_zmiany)
);

CREATE INDEX idx_dyz_dyspozytor ON dyspozytorzy_zmiany(id_dyspozytora);
CREATE INDEX idx_dyz_zmiana     ON dyspozytorzy_zmiany(id_zmiany);
