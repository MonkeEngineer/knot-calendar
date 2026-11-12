# Knot Calendar

[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](https://www.python.org/downloads/)
[![Django](https://img.shields.io/badge/Django-%23092E20.svg?logo=django&logoColor=white)](https://www.djangoproject.com/)
[![MIT License](https://img.shields.io/badge/MIT%20License-FFFFFF)](LICENSE)

A self-hosted calendar and event management server built with Django and PostgreSQL. Named after 结绳记事 (jié shéng jì shì), the ancient practice of tying knots to record events.

## Getting Started

### Prerequisites

- [uv](https://docs.astral.sh/uv/getting-started/installation/) — uv will install Python 3.14 automatically if it is not already on your system.

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/MonkeEngineer/knot-calendar.git
   cd knot-calendar
   ```

2. Install dependencies:

   ```bash
   uv sync
   ```

3. Create your local environment file:

   ```bash
   cp .env.example .env
   ```

4. Generate a secret key and add it to `.env`:

   ```bash
   uv run python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```

   Open `.env` and set `SECRET_KEY` to the output. If the value contains `#` or `$`, wrap it in single quotes.

5. Load the environment file in your shell:

   ```bash
   export UV_ENV_FILE=.env
   ```

6. Run the database migrations:

   ```bash
   uv run python manage.py migrate
   ```

7. Create an admin user:

   ```bash
   uv run python manage.py createsuperuser
   ```

8. Start the development server:

   ```bash
   uv run python manage.py runserver
   ```

   Then open [http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin/) and log in with the credentials you created.

## Contributing

Contributions are welcome! Please open an issue before starting work on a significant change so we can discuss the approach. See [CONTRIBUTING.md](CONTRIBUTING.md) for branching conventions, commit message format, and pull request guidelines.

## License

This project is licensed under the [MIT License](LICENSE).
