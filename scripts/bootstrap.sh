#!/usr/bin/env bash
#
# Apply the Ecosystem Admin repository conventions to a GitHub repository:
#   - labels (scripts/labels.json)
#   - repository settings: squash commit uses the PR title and body,
#     head branches are deleted after merge
#   - the "main protection" ruleset (scripts/ruleset-main.json)
#
# Safe to run more than once: labels and the ruleset are created or updated.
# Other labels and rulesets are left alone unless --prune is given.
#
# Usage: scripts/bootstrap.sh [--prune] [owner/repo]
#   --prune  also delete labels that are not defined in labels.json
#            (useful on a new repository to remove GitHub's default labels)
#   Without a repository, the one of the current directory is used.
#
# Requires: gh (authenticated, with admin access to the repository) and jq.

set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
prune_args=()
repo=""
for arg in "$@"; do
  case "$arg" in
    --prune) prune_args=(--prune) ;;
    *) repo="$arg" ;;
  esac
done
if [[ -z "$repo" ]]; then
  repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
fi

echo "Bootstrapping $repo"

echo "Syncing labels"
"$dir/sync-labels.sh" "${prune_args[@]}" "$repo"

echo "Updating repository settings"
gh api "repos/$repo" --method PATCH --silent \
  -F delete_branch_on_merge=true \
  -F allow_squash_merge=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY

apply_ruleset() {
  local ruleset_file="$dir/ruleset-main.json"
  local ruleset_name ruleset_id
  ruleset_name="$(jq -r .name "$ruleset_file")"
  ruleset_id="$(gh api "repos/$repo/rulesets" --jq ".[] | select(.name == \"$ruleset_name\") | .id")"
  if [[ -n "$ruleset_id" ]]; then
    gh api "repos/$repo/rulesets/$ruleset_id" --method PUT --input "$ruleset_file" --silent
  else
    gh api "repos/$repo/rulesets" --method POST --input "$ruleset_file" --silent
  fi
}

echo "Applying ruleset"
if ! output="$(apply_ruleset 2>&1)"; then
  if [[ "$output" == *"Upgrade to GitHub Pro"* ]]; then
    echo "Error: rulesets are not available for private repositories on the free plan." >&2
    echo "Labels and settings were applied. Make $repo public or upgrade the plan, then run this script again." >&2
  else
    echo "$output" >&2
  fi
  exit 1
fi

echo "Done"
