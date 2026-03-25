# pogotowie_db - Emergency Medical Services Database

A relational database system for managing emergency medical service operations,
built with PostgreSQL as part of a university database course project.

## Overview

The system handles dispatch management, ambulance deployment, medical documentation,
staff scheduling, and access control - covering the full operational cycle
of an emergency medical station.

## Tech Stack

- **PostgreSQL 17** - database engine
- **DBeaver** - SQL client
- **Docker** - containerized deployment
- **Git / GitHub** - version control

## Database Structure

- 14 tables (13 operational + audit log)
- 3 triggers — ambulance status automation, status change logging, team size validation
- 3 views — dispatch details, patient history, dispatcher workload
- 3 roles — `dyspozytor`, `ratownik`, `admin_pogotowie`
- 8 SQL queries covering core operational use cases

## Running Locally with Docker

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Clone the repository
3. Run:
   ```bash
   docker-compose up
4. Connect via DBeaver or pgAdmin:
    - Host: localhost | Port: 5433
    - Database: pogotowie_db
    - User: postgres | Password: postgres

## Author
Damian Baliński - 123702 
