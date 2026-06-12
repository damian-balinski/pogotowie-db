# Uruchomienie bazy danych pogotowie_db

## Wymagania
Docker Desktop: https://www.docker.com/products/docker-desktop/

## Pliki w repozytorium
- `docker-compose.yml`       — konfiguracja kontenera
- `.env`                     — zmienne środowiskowe (dane logowania)
- `init_roles.sql`           — definicje ról użytkowników (wykonywany jako pierwszy)
- `pogotowie_db_backup.sql`  — pełny backup bazy danych (wykonywany jako drugi)

## Kroki uruchomienia

1. Zainstaluj Docker Desktop i uruchom go
   (poczekaj aż ikona w zasobniku systemowym stanie się aktywna)

2. Pobierz repozytorium jako ZIP lub sklonuj:
   git clone https://github.com/damian-balinski/pogotowie-db.git

3. Otwórz terminal w folderze projektu i wpisz:
   docker-compose up -d

4. Poczekaj kilka sekund, a następnie sprawdź czy baza działa:
   docker-compose logs postgres | tail -5
   (szukaj linii: "database system is ready to accept connections")

5. Połącz się z bazą przez DBeaver lub pgAdmin:
   - Host:     localhost
   - Port:     5433
   - Database: pogotowie_db
   - User:     postgres
   - Password: postgres

## Podgląd tabel przez terminal

Sprawdź listę tabel:

    docker-compose exec postgres psql -U postgres -d pogotowie_db -c "\dt"

Sprawdź liczbę rekordów w wybranej tabeli:

    docker-compose exec postgres psql -U postgres -d pogotowie_db -c "SELECT COUNT(*) FROM wezwania;"

Wyświetl przykładowe dane:

    docker-compose exec postgres psql -U postgres -d pogotowie_db -c "SELECT * FROM wezwania LIMIT 5;"

Wejście do interaktywnej konsoli SQL:

    docker-compose exec postgres psql -U postgres -d pogotowie_db

## Reset bazy danych

Aby przywrócić bazę do stanu początkowego (ponownie uruchamia skrypty inicjalizacyjne):

    docker-compose down -v && docker-compose up -d

Flaga `-v` usuwa wolumin z danymi. Baza zostanie automatycznie odtworzona z pliku backup.

## Zawartość bazy
- 14 tabel (13 operacyjnych + log_wezwan)
- Dane testowe (20 wezwań, 15 wyjazdów, 10 pacjentów i inne)
- 3 triggery (status karetki, log statusów, walidacja zespołu)
- 3 widoki (szczegóły wyjazdu, historia pacjenta, obciążenie dyspozytorni)
- 3 role użytkowników (dyspozytor, ratownik, admin_pogotowie)

## Zatrzymanie bazy

    docker-compose down