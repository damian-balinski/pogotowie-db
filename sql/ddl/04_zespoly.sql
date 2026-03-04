CREATE TABLE zespoly (
    id_zespolu    SERIAL PRIMARY KEY,
    nazwa_zespolu VARCHAR(100) NOT NULL,
    typ_zespolu   VARCHAR(20)  NOT NULL
                  CHECK (typ_zespolu IN ('podstawowy', 'specjalistyczny', 'reanimacyjny'))
);
