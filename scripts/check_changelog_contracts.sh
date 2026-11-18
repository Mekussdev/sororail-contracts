#!/usr/bin/env bash
set -euo pipefail

# A contract ABI or behavior change must be visible to integrators.
base="${1:-origin/main}"
changed="$(git diff --name-only "$base"...HEAD)"

if ! grep -Eq '^contracts/(escrow|stream|vesting|recurring|batch_payout|common)/' <<<"$changed"; then
  exit 0
fi

if grep -qx 'CHANGELOG.md' <<<"$changed"; then
  exit 0
fi

echo "Contract-affecting changes require an Unreleased entry in CHANGELOG.md." >&2
exit 1
