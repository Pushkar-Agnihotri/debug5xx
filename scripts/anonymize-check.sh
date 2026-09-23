#!/usr/bin/env bash
# Fails if any tracked file mentions a term from the private pattern list.
# The list is kept OUTSIDE this public repo (default: ~/personal/.anonymize-patterns),
# because the list itself would reveal what we are hiding.
set -euo pipefail
cd "$(dirname "$0")/.."

PATTERNS=${ANONYMIZE_PATTERNS:-$HOME/personal/.anonymize-patterns}
[ -f "$PATTERNS" ] || { echo "pattern file not found: $PATTERNS" >&2; exit 2; }

regex=$(grep -v '^\s*$' "$PATTERNS" | paste -sd'|' -)
files=$(git ls-files | grep -v -E 'package-lock\.json$|\.woff2?$')

if echo "$files" | xargs grep -n -i -E "$regex"; then
  echo "FAIL: remove the matches above before publishing" >&2
  exit 1
fi

# Commit metadata must use the personal identity only.
if git log --format='%ae%n%ce' | grep -v -x "$(git config user.email)"; then
  echo "FAIL: commits with a different email found" >&2
  exit 1
fi

echo "anonymize check: clean"
