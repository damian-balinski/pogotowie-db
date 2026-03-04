CREATE TABLE wezwania (
    id_wezwania        SERIAL PRIMARY KEY,
    id_dyspozytora     INTEGER      NOT NULL REFERENCES dyspozytorzy(id_dyspozytora),
    data_zgloszenia    DATE         NOT NULL,
    godzina_zgloszenia TIME         NOT NULL,
    adres              VARCHAR(200) NOT NULL,
    miasto             VARCHAR(100) NOT NULL,
    priorytet          VARCHAR(2)   NOT NULL CHECK (priorytet IN ('P1', 'P2', 'P3')),
    opis_zdarzenia     TEXT,
    status             VARCHAR(20)  NOT NULL DEFAULT 'NOWE'
                                    CHECK (status IN ('NOWE', 'W_REALIZACJI', 'ZAKONCZONE', 'ANULOWANE'))
);

CREATE INDEX idx_wezwania_dyspozytor ON wezwania(id_dyspozytora);
CREATE INDEX idx_wezwania_status     ON wezwania(status);
CREATE INDEX idx_wezwania_data       ON wezwania(data_zgloszenia);
