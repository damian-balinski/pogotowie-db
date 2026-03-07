INSERT INTO udzielona_pomoc (id_wyjazdu, id_pacjenta, id_swiadczenia,
                             godzina_wykonania, wynik, uwagi) VALUES
-- Wyjazd 1 – zawał (pacjent 1)
(1, 1,  3, '2025-01-10 08:37', 'wykonano', 'STEMI – uniesienie ST w II, III, aVF'),
(1, 1,  9, '2025-01-10 08:39', 'wykonano', 'Kaniula 18G lewa ręka'),
(1, 1, 10, '2025-01-10 08:40', 'wykonano', 'NaCl 500ml'),
(1, 1, 13, '2025-01-10 08:41', 'wykonano', 'NTG s.l. 0.4mg'),
-- Wyjazd 2 – wypadek (pacjent 2)
(2, 2, 19, '2025-01-10 21:57', 'wykonano', 'GCS 12'),
(2, 2,  4, '2025-01-10 21:58', 'wykonano', 'RR 100/70'),
(2, 2, 20, '2025-01-10 22:00', 'wykonano', 'Kołnierz Philadelphia'),
-- Wyjazd 3 – udar (pacjent 3)
(3, 3, 19, '2025-01-11 09:24', 'wykonano', 'GCS 9, asymetria twarzy'),
(3, 3,  5, '2025-01-11 09:25', 'wykonano', 'SpO2 91%'),
(3, 3,  6, '2025-01-11 09:26', 'wykonano', 'O2 8l/min maska'),
(3, 3,  9, '2025-01-11 09:28', 'wykonano', 'Kaniula 18G'),
-- Wyjazd 5 – napad padaczkowy (pacjent 5)
(5, 5, 19, '2025-01-11 22:32', 'wykonano', 'GCS 8 po napadzie'),
(5, 5,  6, '2025-01-11 22:33', 'wykonano', 'Tlenoterapia bierna'),
-- Wyjazd 6 – niemowlę (pacjent 6)
(6, 6,  1, '2025-01-12 08:16', 'wykonano', 'RKO u niemowlęcia – 30:2'),
(6, 6,  7, '2025-01-12 08:18', 'wykonano', 'Defibrylacja 4J/kg'),
-- Wyjazd 9 – politrauma (pacjent 8)
(9, 8, 18, '2025-01-13 08:54', 'wykonano', 'FAST – płyn wolny w jamie brzusznej'),
(9, 8, 20, '2025-01-13 08:55', 'wykonano', 'Pełna immobilizacja'),
(9, 8,  9, '2025-01-13 08:57', 'wykonano', 'Dwa wkłucia obwodowe'),
(9, 8, 10, '2025-01-13 08:58', 'wykonano', 'Przetoczono 1000ml Ringera'),
-- Wyjazd 14 – RKO po utopieniu (pacjent 10)
(14,10,  1, '2025-01-15 08:24', 'wykonano', 'RKO wdrożone natychmiast'),
(14,10,  2, '2025-01-15 08:26', 'wykonano', 'Intubacja dotchawicza rozmiar 7.5'),
(14,10, 11, '2025-01-15 08:28', 'wykonano', 'Adrenalina 1mg i.v. × 3'),
-- Wyjazd 15 – hipoglikemia (pacjent 9)
(15, 9,  8, '2025-01-15 10:44', 'wykonano', 'Glukoza 42 mg/dl'),
(15, 9, 12, '2025-01-15 10:46', 'wykonano', 'Glukoza 40% 40ml i.v.');
