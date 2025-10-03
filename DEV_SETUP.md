# Dev setup

This project supports two local workflows:

1. Quick local development (SQLite, no Docker)

- From the repo root:

```bash
cd backend
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

- Default dev user created by seeds: `admin@example.com` / `password` (see `backend/db/seeds.rb`).

2. Docker compose (Postgres + Redis)

- Use the Makefile convenience target:

```bash
make setup
```

- This will copy `.env.example` to `backend/.env` if missing, build images, bring the stack up and run `bin/rails db:prepare` inside the `web` service.

Notes
- `.env` is gitignored; use `.env.example` as reference and set real secrets in your local `.env`.
- For interview/demo, the sqlite workflow is the fastest and does not require Docker.
