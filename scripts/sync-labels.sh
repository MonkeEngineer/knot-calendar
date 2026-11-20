#!/usr/bin/env bash
#
# Create or update the labels defined in labels.json on a GitHub repository.
# Existing labels with the same name are updated; other labels are left alone
# unless --prune is given.
#
# Usage: scripts/sync-labels.sh [--prune] [owner/repo]
#   --prune  also delete labels that are not defined in labels.json
#            (useful on a new repository to remove GitHub's default labels)
#   Without a repository, the one of the current directory is used.
#
# Requires: gh (authenticated) and jq.

set -euo pipefail

labels_file="$(dirname "$0")/labels.json"
prune=false
repo=""
for arg in "$@"; do
  case "$arg" in
    --prune) prune=true ;;
    *) repo="$arg" ;;
  esac
done

repo_args=()
if [[ -n "$repo" ]]; then
  repo_args=(--repo "$repo")
fi

jq -r '.[] | [.name, .color, .description] | @tsv' "$labels_file" |
  while IFS=$'\t' read -r name color description; do
    gh label create "$name" --color "$color" --description "$description" --force "${repo_args[@]}"
  done

if [[ "$prune" == true ]]; then
  wanted="$(jq -r '.[].name' "$labels_file")"
  gh label list --limit 200 --json name --jq '.[].name' "${repo_args[@]}" |
    while IFS= read -r name; do
      if ! grep -qxF -- "$name" <<<"$wanted"; then
        gh label delete "$name" --yes "${repo_args[@]}"
        echo "Deleted label: $name"
      fi
    done
fi
