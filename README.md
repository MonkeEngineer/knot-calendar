# Knot Calendar

[![AGPLv3](https://img.shields.io/badge/AGPLv3-FFFFFF)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.14-3776AB?logo=python&logoColor=fff)](https://www.python.org/)
[![Django](https://img.shields.io/badge/Django-6.1-%23092E20.svg?logo=django&logoColor=white)](https://www.djangoproject.com/)
[![Ruff](https://custom-icon-badges.demolab.com/badge/Ruff-261230.svg?logo=ruff-logo)](https://docs.astral.sh/ruff/)

A self-hosted calendar where every occurrence of a recurring event keeps its own checklist and record. Named after 结绳记事 (jié shéng jì shì), the ancient practice of tying knots to record events.

## Getting started

### Prerequisites

- [Python 3.14](https://www.python.org/)
- [uv](https://docs.astral.sh/uv/)
- [git](https://git-scm.com/)

### Setup

1. Clone the repository and move into it:

   ```shell
   git clone https://github.com/MonkeEngineer/knot-calendar.git
   cd knot-calendar
   ```

2. Install dependencies:

   ```shell
   uv sync
   ```

3. Copy `.env.example` to `.env`:

   ```shell
   cp .env.example .env
   ```

4. Generate a secret key and paste it inside the single quotes of `DJANGO_SECRET_KEY` in `.env`:

   ```shell
   uv run python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```

5. Apply migrations:

   ```shell
   uv run --env-file .env python manage.py migrate
   ```

6. Start the development server:

   ```shell
   uv run --env-file .env python manage.py runserver
   ```

## Development

Commands that touch the database or settings need `--env-file .env`. Export `UV_ENV_FILE=.env` once in your shell to skip passing it on every command.

### Linting

To lint and format with Ruff, run these commands:

```shell
uv run ruff check
uv run ruff format
```

### Testing

To run the test suite with pytest, run this command:

```shell
uv run --env-file .env pytest
```

### Pre-commit

To install the local pre-commit hooks, run this command:

```shell
uv run pre-commit install
```

## License

This project is under the [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html). You are free to use, modify, and distribute it, but any modified version you deploy over a network must also be made available under the same license.
