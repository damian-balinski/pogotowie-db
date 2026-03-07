INSERT INTO sklad_zespolu (id_zespolu, id_pracownika, rola_w_zespole) VALUES
-- Alfa-1 (P): kierowca + ratownik
(1, 13, 'kierowca'),
(1,  1, 'ratownik_medyczny'),
-- Alfa-2 (P): kierowca + ratownik
(2, 14, 'kierowca'),
(2,  2, 'ratownik_medyczny'),
-- Beta-1 (S): kierowca + 2 ratowników
(3, 15, 'kierowca'),
(3,  4, 'ratownik_medyczny'),
(3,  5, 'ratownik_medyczny'),
-- Beta-2 (S): kierowca + ratownik
(4, 13, 'kierowca'),
(4,  6, 'ratownik_medyczny'),
-- Gamma-1 (R): kierowca + lekarz + ratownik
(5, 14, 'kierowca'),
(5,  3, 'lekarz'),
(5,  8, 'ratownik_medyczny'),
-- Gamma-2 (R): kierowca + lekarz + ratownik
(6, 15, 'kierowca'),
(6,  7, 'lekarz'),
(6,  9, 'ratownik_medyczny');
