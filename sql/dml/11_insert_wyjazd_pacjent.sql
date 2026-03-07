INSERT INTO wyjazd_pacjent (id_wyjazdu, id_pacjenta,
                            stan_przy_przyjeciu, stan_przy_przekazaniu, miejsce_przekazania) VALUES
(1,  1, 'krytyczny',  'stabilny',   'USK im. WAM Łódź'),
(2,  2, 'ciężki',     'stabilny',   'SOR Biegańskiego'),
(2,  4, 'umiarkowany','dobry',      'SOR Biegańskiego'),
(3,  3, 'krytyczny',  'stabilny',   'USK im. WAM Łódź'),
(4,  4, 'lekki',      'dobry',      'SOR Kopernika'),
(5,  5, 'umiarkowany','stabilny',   'SOR Biegańskiego'),
(6,  6, 'krytyczny',  'krytyczny',  'USK im. WAM Łódź'),
(8,  7, 'umiarkowany','stabilny',   'SOR Biegańskiego'),
(9,  8, 'krytyczny',  'ciężki',     'USK im. WAM Łódź'),
(10, 9, 'ciężki',     'stabilny',   'SOR Kopernika'),
(14,15,NULL,NULL,NULL), -- wyjazd 14 bez przekazania (zamknięto na miejscu)
(15,10,'krytyczny',  'stabilny',    'USK im. WAM Łódź'),
(16, 9, 'ciężki',    'dobry',       'SOR Kopernika');
