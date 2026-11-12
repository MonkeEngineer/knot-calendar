---
title: Django DEFAULT_LOGGING causes duplicate log lines and makes LOG_LEVEL ineffective
date: 2026-11-12
category: runtime-errors
module: config
problem_type: runtime_error
component: observability
symptoms:
  - "With DEBUG=True, every django.* log record (except django.server, which has propagate: False) appears twice on the console"
  - LOG_LEVEL=WARNING does not suppress django.server INFO request lines
  - LOG_LEVEL=DEBUG does not enable debug output from django.db.backends or other django.* loggers
root_cause: config_error
resolution_type: config_change
severity: medium
framework_version: django 6.1.3
tags:
  - logging
  - django
  - disable_existing_loggers
  - LOG-LEVEL
  - duplicate-logs
  - django-server
---

# Django DEFAULT_LOGGING causes duplicate log lines and makes LOG_LEVEL ineffective

## Problem

Django's `DEFAULT_LOGGING` pre-wires the `django` and `django.server` loggers with their own handlers. Setting `disable_existing_loggers: False` and adding a root handler preserves those loggers but does not remove their DEFAULT_LOGGING handlers, causing each record to print twice. Setting `LOG_LEVEL` only on the root logger has no effect on the `django.*` loggers whose levels and handlers are still controlled by DEFAULT_LOGGING.

## Symptoms

- With `DEBUG=True`, every `django.*` log record (except `django.server`, which has `propagate: False` and does not reach the root handler) appears twice — once from Django's default `console` handler (require_debug_true filter), and once from the root handler.
- `LOG_LEVEL=WARNING` does not suppress `django.server` INFO request lines because `django.server` retains its DEFAULT_LOGGING level and `propagate: False`.
- `LOG_LEVEL=DEBUG` does not enable debug output from `django.db.backends` or other `django.*` loggers because the `django` logger's explicit INFO level in DEFAULT_LOGGING blocks them upstream.

## What Didn't Work

1. **`disable_existing_loggers: False` alone with a root handler.** This keeps existing logger objects alive (correct — it prevents silencing them) but does not remove their DEFAULT_LOGGING handlers. The `django` logger keeps `console` (DEBUG=True only) and `mail_admins`, and both it and root emit the record.

2. **Overriding `django.server` with `handlers: ["console"], level: "INFO", propagate: False`.** Prevents duplicates for that logger but hardcodes its level to INFO, making `LOG_LEVEL` ineffective for runserver request lines. Also doesn't address the `django` logger's handlers. (session history: this was the first config applied; the duplicate issue showed up during the code-review pass)

## Solution

Explicitly clear the handlers on the `django` and `django.server` loggers and re-enable propagation for `django.server`, so every record flows through the single root handler with the shared `_LOG_LEVEL`:

```python
# config/settings.py:89-114
_LOG_LEVEL = env("LOG_LEVEL", default="INFO").upper()

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "console": {
            "format": "{asctime} {levelname} {name} {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "console",
        },
    },
    "loggers": {
        "django": {"handlers": [], "level": _LOG_LEVEL, "propagate": True},
        "django.server": {"handlers": [], "level": _LOG_LEVEL, "propagate": True},
    },
    "root": {
        "handlers": ["console"],
        "level": _LOG_LEVEL,
    },
}
```

## Why This Works

Django merges the project's `LOGGING` dict onto DEFAULT_LOGGING after `django.setup()`. `disable_existing_loggers: False` preserves existing logger objects but does **not** strip their handlers — the merge is additive for `handlers` unless you set an explicit empty list. Setting `"handlers": []` in the merge overwrites the DEFAULT_LOGGING handler lists (`["console", "mail_admins"]` on `django` and `["django.server"]` on `django.server`), so only the root handler receives records.

`django.server` defaults to `propagate: False` in DEFAULT_LOGGING (verified against Django 6.1.3: `"django.server": {"handlers": ["django.server"], "level": "INFO", "propagate": False}`). Setting `"propagate": True` in the project config overrides this, allowing runserver request lines to reach the root handler like everything else.

Setting `"level": _LOG_LEVEL` on both named loggers lets `LOG_LEVEL` control verbosity across all loggers from a single env variable.

Side effect: the `mail_admins` handler is removed from the `django` logger. If error emails are needed in production, add a `mail_admins` handler explicitly.

## Prevention

- When adding any project-level `LOGGING` config to Django, check `DEFAULT_LOGGING` in `django.utils.log` for pre-wired loggers. As of Django 6.1.3, `django` and `django.server` both have explicit handlers that survive `disable_existing_loggers: False`.
- To verify no duplicates after a config change: with `DEBUG=True`, make a request and count how many times the request line appears in the console. One line = correct. Two lines = handler leak from DEFAULT_LOGGING.
- `LOG_LEVEL` only controls verbosity when it is applied to both the named `django` loggers and the root logger. Setting it only on root has no effect on Django's own loggers.

## Related Issues

- [#5 Console logging setup with configurable log level](https://github.com/MonkeEngineer/knot-calendar/issues/5) — the issue this fix was implemented under
