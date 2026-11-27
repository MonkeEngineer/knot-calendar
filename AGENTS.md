# AGENTS.md

This file provides guidance to AI agents (Claude Code, Codex, Gemini CLI, etc.) when working with code in this repository.

## Project

Knot Calendar is a self-hosted calendar where every occurrence of a recurring event keeps its own checklist and record. Named after 结绳记事 (jié shéng jì shì), the ancient practice of tying knots to record events.

The project is licensed under AGPLv3: modifications deployed over a network must be released under the same license.

## Branching

This project follows [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow):

- `main` is always deployable.
- All changes happen on short-lived feature branches created from `main`.
- Branch naming: `<type>/<issue-number>-<short-description>` (e.g. `feat/12-recurring-events`).
- Open a PR to merge back into `main`; PRs require at least one approval.
- Delete the branch after merge.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `chore`, `refactor`, `style`, `test`, `docs`, `ci`, `revert`.  
`chore` covers build tooling, dependencies, Docker, config, and project setup. `style` is for formatting-only changes with no behavior change (e.g. a linter's format pass). `ci` is specific to CI/CD pipeline changes (GitHub Actions workflows).  
Scope is optional; use it when the change is clearly scoped to one area (e.g. `feat(calendar): ...`).  
Breaking changes: append `!` after the type/scope and add a `BREAKING CHANGE:` footer.

One logical change per commit — do not bundle unrelated changes together.

Add a body only when the subject line is not enough to explain the why (e.g. a non-obvious constraint, a workaround, a breaking change). Otherwise keep it to the subject line alone.

## Pull requests

One concern per PR, mirroring commit granularity. The PR title follows the same conventional commit format as the commit subject line.

**Ruleset (enforced on `main`):**

- Direct pushes and force pushes to `main` are not allowed — all changes go through a PR.
- Branches are deleted automatically after merge.
- Status checks will be required once a CI pipeline is in place.

**After merging:** pull `main` locally and delete the local branch (`git branch -d <branch>`).

**Merge method:** squash only — merge commits and rebase merges are disabled. The PR title and body are used as the squash commit message, so keep them accurate.

## Documented solutions

`docs/solutions/` holds documented solutions to past problems (bugs, best practices, workflow patterns), organized by category with YAML frontmatter (`module`, `tags`, `problem_type`). Relevant when implementing or debugging in documented areas.

## Status

The repository is in initial setup. No build tooling, language, or framework has been chosen yet. Update this file once the stack is decided — commands, architecture, and conventions all belong here.
