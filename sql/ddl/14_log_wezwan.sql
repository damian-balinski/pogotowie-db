CREATE TABLE log_wezwan (
    id           SERIAL PRIMARY KEY,
    id_wezwania  INTEGER      NOT NULL,
    stary_status VARCHAR(20),
    nowy_status  VARCHAR(20),
    zmieniono_o  TIMESTAMP    DEFAULT NOW(),
    uzytkownik   VARCHAR(100) DEFAULT CURRENT_USER
);
