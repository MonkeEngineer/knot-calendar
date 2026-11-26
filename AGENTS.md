# AGENTS.md

This file provides guidance to AI agents (Claude Code, Codex, Gemini CLI, etc.) when working with code in this repository.

## Project

Knot Calendar is a self-hosted calendar where every occurrence of a recurring event keeps its own checklist and record. Named after 结绳记事 (jié shéng jì shì), the ancient practice of tying knots to record events.

The project is licensed under AGPLv3: modifications deployed over a network must be released under the same license.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `ci`, `revert`.  
Scope is optional; use it when the change is clearly scoped to one area (e.g. `feat(calendar): ...`).  
Breaking changes: append `!` after the type/scope and add a `BREAKING CHANGE:` footer.

## Status

The repository is in initial setup. No build tooling, language, or framework has been chosen yet. Update this file once the stack is decided — commands, architecture, and conventions all belong here.
