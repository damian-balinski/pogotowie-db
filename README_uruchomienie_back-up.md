# Uruchomienie bazy danych pogotowie_db

## Wymagania
Docker Desktop: https://www.docker.com/products/docker-desktop/

## Pliki w repozytorium
- `docker-compose.yml`       — konfiguracja kontenera
- `init_roles.sql`           — definicje ról użytkowników (wykonywany jako pierwszy)
- `pogotowie_db_backup.sql`  — pełny backup bazy danych (wykonywany jako drugi)

## Kroki uruchomienia

1. Zainstaluj Docker Desktop i uruchom go
   (poczekaj aż ikona w zasobniku systemowym stanie się aktywna)

2. Pobierz repozytorium jako ZIP lub sklonuj:
   git clone https://github.com/damian-balinski/pogotowie-db.git

3. Otwórz terminal w folderze projektu i wpisz:
   docker-compose up

4. Poczekaj na komunikat:
   database system is ready to accept connections

5. Połącz się z bazą przez DBeaver lub pgAdmin:
   - Host:     localhost
   - Port:     5433
   - Database: pogotowie_db
   - User:     postgres
   - Password: postgres

## Zawartość bazy
- 14 tabel (13 operacyjnych + log_wezwan)
- Dane testowe (20 wezwań, 15 wyjazdów, 10 pacjentów i inne)
- 3 triggery (status karetki, log statusów, walidacja zespołu)
- 3 widoki (szczegóły wyjazdu, historia pacjenta, obciążenie dyspozytorni)
- 3 role użytkowników (dyspozytor, ratownik, admin_pogotowie)

## Zatrzymanie bazy
W terminalu: Ctrl+C, następnie:
docker-compose down -v
