#!/bin/bash
# Publish allowlist gate for critical-objective-outputs (PUBLIC repo).
#
# This repo is a one-way publish surface for *non-sensitive* feed artifacts.
# Intelligence work-product (rankings, curated universe, sector taxonomy,
# monitor signals, anything scoring-related) must never land here — even
# transiently in a commit, because the blob stays in git history forever.
#
# Rather than rely on reviewers noticing a wrong file in a daily auto-commit,
# this script rejects anything not on an explicit allowlist. It is invoked
# from two places:
#   1. daily_run.sh Step 6, before `git push`  (catches pipeline accidents)
#   2. .githooks/pre-commit                     (catches manual accidents)
#
# To allow a new file type here, add it to ALLOWLIST below in the same PR
# that introduces the producer. No one-off exceptions.
#
# Exit codes:
#   0  — everything tracked + staged is on the allowlist
#   1  — disallowed file found (message lists offenders)
#   2  — script misuse (not inside the outputs repo)
#
# Compatible with bash 3.2 (macOS default) — no mapfile, no assoc arrays.

set -eu

# Allowlist. Entries are matched as exact paths OR shell globs against
# paths relative to the repo root. Keep this list minimal.
ALLOWLIST="
feed_greenhouse.xml
feed_ashby.xml
feed_lever.xml
jobs.json
feed.csv
data/jobs/jobs.json
data/jobs/jobs.raw.json
README.md
LICENSE
.gitignore
.gitattributes
scripts/check_publish_allowlist.sh
.githooks/pre-commit
.githooks/install.sh
"

is_allowed() {
  path="$1"
  for pattern in $ALLOWLIST; do
    # shellcheck disable=SC2053
    case "$path" in
      $pattern) return 0 ;;
    esac
  done
  return 1
}

# Must run inside the outputs repo.
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "check_publish_allowlist: not inside a git repo" >&2
  exit 2
fi
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Collect candidate paths: tracked + staged, deduped via sort -u.
CANDIDATES="$(
  { git ls-files; git diff --cached --name-only; } | sort -u
)"

VIOLATIONS=""
COUNT=0
while IFS= read -r path; do
  [ -z "$path" ] && continue
  COUNT=$((COUNT + 1))
  if ! is_allowed "$path"; then
    VIOLATIONS="$VIOLATIONS$path
"
  fi
done <<EOF
$CANDIDATES
EOF

if [ -z "$VIOLATIONS" ]; then
  echo "✓ publish allowlist check passed ($COUNT paths)"
  exit 0
fi

echo "✗ publish allowlist check FAILED — disallowed paths present:" >&2
printf '%s' "$VIOLATIONS" | sed 's/^/    /' >&2
cat >&2 <<'MSG'

critical-objective-outputs is a PUBLIC repo. Only the explicit allowlist in
scripts/check_publish_allowlist.sh may land here. If one of the paths above
is legitimately public, add it to the allowlist in the same commit. If it
is private intelligence or internal tooling, publish it to the private
website repo (critical-objective-web) instead.

MSG
exit 1
