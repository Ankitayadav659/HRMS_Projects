# Attendance & Salary Management Portal — Phase 1 sample

Admin-only web app: import the monthly eSSL attendance report, review exceptions,
calculate salary with the confirmed payroll rules, approve and lock payroll.

## Run it (Windows or Linux)

Needs Python 3.12 or newer.

```bash
python -m venv .venv
# Windows:  .venv\Scripts\activate      Linux: source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_demo          # demo admin + 3 employees + imports samples/essl_2026_08.pdf
python manage.py runserver 127.0.0.1:8000
```

Open http://127.0.0.1:8000 and log in:

| Username | Password |
|---|---|
| `admin` | `Office@Demo2026` |

**Change this password before real use** (`python manage.py changepassword admin`).
Five wrong passwords lock the username for 15 minutes.

Run the tests: `python manage.py test`

To start again from an empty demo: delete `db.sqlite3` and the `media` folder, then run `migrate` and `seed_demo` again.

## Demo data

- Employees: only IDs **6** (Ranjana Besharkar, 35,000), **16** (Trusha Patel, 23,000) and **19** (Raghunath Naik, 35,000),
  weekly off **Sunday only** (office rule), shift 09:30–18:30. No joining dates were given, so they are blank.
- `samples/essl_2026_08.pdf` is imported through the real import flow with "Skip unknown IDs". 93 rows were imported and
  527 rows for the 17 other IDs were skipped, but they are kept in the import (Import → #1 → "All rows read from file").
- No leave or holiday records exist, so every no-punch working day shows **Reason pending**.
- `samples/essl_2026_09_partial.pdf` has **not** been imported. Upload it on the Import page to see the "partial month / day in progress" handling.

## Monthly workflow

1. **Import**: upload the eSSL PDF. Check the preview (counts, unknown IDs, single punches, conflicts), then press Import or Cancel.
2. **Exceptions**: resolve missing punches (enter the missing time or set a reason), reason-pending days, conflicts and missing salaries.
3. **Absence reasons / Holidays**: set leave, suspension and so on for a date range, or create a holiday for everyone.
4. **Payroll**: check each employee's breakdown and add bonus or advance adjustments. **Approve** locks the month.
   **Reopen** needs a reason and the month must then be approved again.
5. **Reports**: download attendance and salary reports (Excel or PDF), plus a full monthly record per employee.

## Moving to the office server

- **PostgreSQL**: `pip install "psycopg[binary]"`, then set these environment variables:
  `PORTAL_DB_ENGINE=postgres`, `PORTAL_DB_NAME`, `PORTAL_DB_USER`, `PORTAL_DB_PASSWORD`, `PORTAL_DB_HOST`, `PORTAL_DB_PORT`.
  Then run `python manage.py migrate`. The code uses no SQLite-only features.
- **Security**: set `PORTAL_DEBUG=0`, a long random `PORTAL_SECRET_KEY`, and `PORTAL_ALLOWED_HOSTS=<server name or IP>`.
  Set `PORTAL_HTTPS=1` if it is served over HTTPS.
- **Web server**: use a WSGI server (`waitress-serve --port=8000 config.wsgi:application` on Windows,
  or gunicorn on Linux) behind IIS or nginx. Run `python manage.py collectstatic`. The screens load Bootstrap from a CDN,
  so the office PCs need internet access, or the Bootstrap file needs to be copied into `static/`.
- **Uploaded files** are stored in `media/`. Set `PORTAL_MEDIA_ROOT` to move them.

## Nightly backup (please set this up)

Back up **both** the database and the `media/` folder (the original uploaded files) every night, and keep copies off the server.

- PostgreSQL: `pg_dump -Fc -U portal portal > backup_YYYY-MM-DD.dump`, scheduled with Windows Task Scheduler or cron.
- SQLite (demo only): copy `db.sqlite3` while the app is stopped.
- Test a restore once a month.

## Git

Git was not installed on the PC where this sample was built, so nothing is committed yet. To start history:

```bash
git init
git add .
git commit -m "Phase 1 sample"
```

## Code map

| Folder | What it does |
|---|---|
| `attendance/parsers/` | `EsslPdfParser` (working) and `EsslExcelParser` (placeholder). Both produce the same normalized rows |
| `attendance/importer.py` | Preview, confirm and cancel; duplicate-file check; conflict detection; waiting rows for unknown IDs |
| `attendance/logic.py` | **Our** day logic: hours, late, early, missing punch, reason pending, weekly off |
| `attendance/reasons.py` | Reasons for date ranges, holidays (reversible, audited) |
| `payroll/calculator.py` | The salary formula and the blocking-issue list |
| `payroll/services.py` | Approve (snapshot + lock) and reopen |
| `core/models.py` | Audit log, login attempts, versioned payroll rules |
| `reports/` | Excel and PDF downloads |
