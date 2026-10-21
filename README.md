# GrandStay Hotel Room Management System — Render PostgreSQL

This project has been adapted from MySQL/PyMySQL to PostgreSQL for deployment on Render.
The schema creates empty tables only; no demo rooms, customers, bookings, or payments are inserted.

## Deploy to Render

1. Push this folder to a GitHub repository. Do not commit `.env`.
2. In Render, create a PostgreSQL database. Use the same region as your web service.
3. Copy the database **Internal Database URL** from Render.
4. Create a Render **Web Service** from the GitHub repository.
5. Set build command: `pip install -r requirements.txt`
6. Set start command: `gunicorn app:app`
7. In the web service's Environment settings, add:
   - `DATABASE_URL` = Render PostgreSQL **Internal Database URL**
   - `SECRET_KEY` = a long random secret
   - `FLASK_DEBUG` = `False`
   - `HOTEL_CURRENCY` = `₹` (optional)
   - `HOTEL_TAX_RATE` = `0.10` (optional)
   - Set actual `HOTEL_NAME`, `HOTEL_PHONE`, `HOTEL_EMAIL`, and `HOTEL_ADDRESS` as appropriate.
8. Deploy. Once the app is running, open `/initialize-database` only if the project exposes it in Settings; otherwise use the schema initialization option in the Settings page. The application connects to the already-created Render database and creates tables without demo records.

## Local development

1. Install Python 3.10+.
2. Copy `.env.example` to `.env`.
3. Fill `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, and `PGDATABASE` for a local PostgreSQL instance, or set `DATABASE_URL`.
4. Install and run:

   ```bash
   python -m venv .venv
   # Windows:
   .venv\\Scripts\\activate
   pip install -r requirements.txt
   python app.py
   ```

5. Visit `http://127.0.0.1:5000`.

## Database notes

- The Render database must already exist; the app does not create a cloud database itself.
- `database/schema.sql` contains PostgreSQL-compatible DDL and creates empty tables only.
- If you already have real records in a separate MySQL database, migrate/export them separately before switching.
- Do not commit credentials or upload `.env` to GitHub.
- Use the database's internal connection URL for the Render web service; do not expose PostgreSQL publicly unless absolutely necessary.
