#!/bin/bash
# One-time installer: point this clone's hooks at the versioned .githooks/
# directory so pre-commit enforcement travels with the repo.
#
# Idempotent — safe to re-run.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit scripts/check_publish_allowlist.sh
echo "✓ installed: core.hooksPath=.githooks"
echo "✓ pre-commit will now run scripts/check_publish_allowlist.sh"
