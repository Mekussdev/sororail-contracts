#!/usr/bin/env bash
set -euo pipefail

# Each stateful SoroRail deployment deliberately owns one instance-storage
# entry: its single lifecycle position. This check makes a new DataKey variant
# (and therefore an extra written entry) an explicit review decision.
stateful=(escrow stream vesting recurring)
for contract in "${stateful[@]}"; do
  source="contracts/${contract}/src/storage.rs"
  variants="$(sed -n '/enum DataKey/,/}/p' "$source" | grep -E '^[[:space:]]*[A-Za-z][A-Za-z0-9_]*,' | wc -l | tr -d ' ')"
  if [ "$variants" != "1" ]; then
    echo "${contract}: expected one instance-storage entry, found ${variants}" >&2
    exit 1
  fi
  grep -q 'impl_single_position_storage!' "$source" || {
    echo "${contract}: must use the single-position storage helper" >&2
    exit 1
  }
done

# Batch payouts are transfer-only and must not gain persistent contract state.
if rg -q 'storage\(\)\.(instance|persistent|temporary)\(' contracts/batch_payout/src; then
  echo 'batch_payout: expected zero contract storage entries' >&2
  exit 1
fi

echo 'storage footprint verified: escrow/stream/vesting/recurring=1, batch_payout=0'
