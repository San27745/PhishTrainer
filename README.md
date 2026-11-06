# PhishTrainer — Phase 1

## Included
- Flask application scaffold
- MySQL connection helper
- Application and database health endpoints
- Initial MySQL schema
- Bootstrap starter homepage

## Important: select one database server
Your PC shows multiple MySQL services and you also use XAMPP. Do not run multiple database servers on the same port. Start the server you choose, check the port shown in XAMPP, then use that same port in `.env`.

XAMPP's bundled server may be MariaDB. MySQL Workbench can generally connect to it over a standard MySQL-compatible TCP connection, although some Workbench administration features may not work.

## Windows setup
Open Command Prompt in this folder and run:

```bat
py -m venv .venv
.venv\Scripts\activate
py -m pip install -r requirements.txt
copy .env.example .env
```

Edit `.env` with your actual host, port, username and password.

## Import database
1. Open Workbench and connect to the same server that you started.
2. Choose File > Open SQL Script.
3. Open `database/phishtrainer.sql`.
4. Click the lightning bolt to execute.
5. Refresh SCHEMAS and confirm `phishtrainer` appears.

## Run app
```bat
py run.py
```
Visit:
- http://127.0.0.1:5000/
- http://127.0.0.1:5000/health
- http://127.0.0.1:5000/health/database

## Security notes
This is a local development starter, not production-ready. Change SECRET_KEY, keep `.env` private, create a dedicated least-privilege database account before deployment, add authentication/CSRF protection/rate limits/email verification/backups/tests, and avoid storing real passwords or unredacted private messages.
