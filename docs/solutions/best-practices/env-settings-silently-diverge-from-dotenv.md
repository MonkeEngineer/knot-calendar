---
title: Env-driven Django settings can silently diverge from what .env says
date: 2026-11-27
category: best-practices
module: config/settings.py
problem_type: best_practice
component: infrastructure
severity: medium
root_cause: config_error
applies_when:
  - Reading Django settings from os.environ with .env loaded by `uv run --env-file`
  - Adding a new env-driven setting that has a default
  - Writing or editing a value in .env or .env.example
tags: [django, settings, uv, dotenv, env-file, secret-key, environ-get]
---

# Env-driven Django settings can silently diverge from what .env says

## Context

Settings read configuration only through `os.environ`. Nothing in Python reads `.env`; uv loads it with `uv run --env-file .env` or `UV_ENV_FILE=.env`. Two behaviors make the value Django sees differ from the line written in `.env`, and neither one raises an error at the place it goes wrong:

1. **uv expands `$` in unquoted `.env` values.** Keys from Django's `get_random_secret_key` can contain `$`, so an unquoted `DJANGO_SECRET_KEY` is silently shortened or altered. The key is still non-empty, so the "key is set" check passes and the app runs on a different key than the one written down. A reviewer raised this while the plan was being reviewed, and the planning session confirmed it with a small `.env` experiment (session history).
2. **`environ.get(name, default)` falls back only when the variable is unset.** A line like `DATABASE_NAME=` sets it to `""`, so the default is skipped. With `BASE_DIR / ""` the database path became the project directory, and `migrate` failed far from the cause with `OperationalError: unable to open database file`. An empty `DJANGO_ALLOWED_HOSTS=` became `[]`, which rejects every request when debug is off. The code review on issue #3 caught this, and a reproduction confirmed it. pytest still passed because pytest-django runs on an in-memory test database.

## Guidance

- Put secret values inside **single quotes** in `.env`, and keep `.env.example` shipping `DJANGO_SECRET_KEY=''` (empty, single-quoted). The empty placeholder fails the existing "missing or empty" check, so an unedited copy can never start the app on a known key (`.env.example:4-5`).
- For any setting with a default, treat empty the same as unset: write `environ.get("NAME") or default`, not `environ.get("NAME", default)` (`config/settings.py:20`, `config/settings.py:64`).
- Where a value must be one of a fixed set, validate it strictly instead of defaulting, so an empty value fails loudly. `DJANGO_DEBUG` keeps `environ.get("DJANGO_DEBUG", "0")` on purpose: `""` is not `'0'` or `'1'`, so it raises `ImproperlyConfigured` (`config/settings.py:15-17`).
- Required values have no default at all: a missing or empty `DJANGO_SECRET_KEY` raises `ImproperlyConfigured`, and the message says how to fix it (`config/settings.py:8-13`).

## Why This Matters

Both failures pass every quick check. The app starts, `manage.py check` is green, and the test suite passes. A silently altered secret key invalidates sessions and signatures for no visible reason. A skipped default shows up later as an unrelated-looking database or `400 Bad Request` error. Writing `environ.get(x) or default` looks like a stylistic quirk, so a future cleanup could "simplify" it back to `environ.get(x, default)` and bring the empty-value bug back.

## When to Apply

- Adding any new `DJANGO_*` or `DATABASE_*` variable to `config/settings.py`.
- Refactoring settings, or replacing `os.environ` with a config library. Check that the library also treats empty as unset.
- Writing setup docs or `.env.example` entries that tell people to paste generated values.

## Examples

Default that silently ignores an empty value, then the fix:

```python
# before: DATABASE_NAME= yields BASE_DIR / "" -> the project directory
"NAME": BASE_DIR / environ.get("DATABASE_NAME", "data/db.sqlite3"),

# after: empty and unset both fall back
"NAME": BASE_DIR / (environ.get("DATABASE_NAME") or "data/db.sqlite3"),
```

Secret key in `.env`:

```shell
# wrong: uv expands $..., so Django receives a shorter key
DJANGO_SECRET_KEY=jqeh%ijul+$%zoq@q)@a*x-lu0)gyw6987ihrla#cuo+9-0mh_h

# right: single quotes stop the expansion
DJANGO_SECRET_KEY='jqeh%ijul+$%zoq@q)@a*x-lu0)gyw6987ihrla#cuo+9-0mh_h'
```

To check that a key arrived unchanged, compare its length inside Django with its length in the file:

```shell
uv run --env-file .env python manage.py shell -c "from django.conf import settings; print(len(settings.SECRET_KEY))"
```

## Related

- Issue #3 (project Django setup), plan `docs/plans/2026-11-27-001-chore-project-django-setup-plan.md` (KTD2-KTD7, U3 verification).
