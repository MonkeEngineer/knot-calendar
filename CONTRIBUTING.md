# Contributing

Thanks for your interest in contributing! A project can add its own CONTRIBUTING.md to extend or replace these guidelines.

## Issues and labels

Before opening an issue, take a quick look at the existing ones to see if it has already been reported. When you open one, we use these labels to keep things organized:

- `bug`: something isn't working as expected
- `enhancement`: a new feature or an improvement request
- `documentation`: improvements or additions to the docs
- `test`: adding or improving tests
- `refactor`: code changes that neither fix a bug nor add a feature
- `chore`: maintenance and tooling work

## Issue template

New issues start from the general template. It has four sections:

- **Summary:** what needs to be done and why, in a few sentences
- **Acceptance criteria:** a checklist of what must be true for the issue to be done
- **Additional notes:** context, constraints, design thoughts, or open questions
- **References:** related issues, pull requests, docs, or links, written as `- [Label](URL)`

Pick the label that fits the issue when you create it. The template doesn't assign labels or assignees by default.

## Branching strategy

We follow [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow):

1. `main` is always in a stable state, so don't commit to it directly.
2. Create a short-lived branch from `main` for each change.
3. Commit your work on that branch and push it.
4. Open a pull request into `main`.
5. Once it's merged, delete the branch.

GitHub deletes the remote branch automatically when the pull request is merged. Your local branch needs to be cleaned up by hand. Because pull requests are squash-merged, `git branch -d` refuses to delete it, so after checking that the pull request was merged use `-D`:

```bash
git switch main
git pull --prune
git branch -D <branch>
```

Name branches `<type>/<issue-number>-<short-description>`, for example `feat/12-login-endpoint`. The type uses the same words as our commit messages ([Conventional Commits](https://www.conventionalcommits.org/)) and matches the label of the issue:

| Label | Branch type |
| --- | --- |
| `enhancement` | `feat` |
| `bug` | `fix` |
| `documentation` | `docs` |
| `test` | `test` |
| `refactor` | `refactor` |
| `chore` | `chore` |

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(<scope>): <short description>
```

For example: `docs(setup): add contributing guidelines`.

- Use the same types as in branch names (`feat`, `fix`, `docs`, `test`, `refactor`, `chore`).
- Keep the description lowercase and short.
- Most commits are a single line, and we don't add credit lines such as `Co-Authored-By`.
- If a change is complicated and needs more explanation, add a body after a blank line to describe what changed and why.

### Merging pull requests

Pull requests are squash-merged, so each one lands on `main` as a single commit. That commit takes the pull request title, which must follow the format above (for example `feat(auth): add login endpoint`). The commits on your branch can be as granular or as rough as you like, and keep one logical change per pull request.

## Pull request template

Pull requests are pre-filled from the pull request template. It has four sections:

- **Summary:** what the pull request does and why, in a few sentences
- **Changes:** the main changes, as a list
- **Related issues:** `Closes #N` so the issue is closed when the pull request is merged, plus any other links written as `- [Label](URL)`
- **Additional notes:** context, trade-offs, follow-ups, or anything a reviewer should know

The text of the pull request becomes the body of the squash commit on `main`, so keep it short and remove any section you don't need.

## License

By contributing, you agree that your contributions will be licensed under the license of the project you are contributing to (see the `LICENSE` file in its repository).
