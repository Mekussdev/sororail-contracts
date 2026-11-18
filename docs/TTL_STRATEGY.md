# TTL strategy and `bump` operations

Soroban can archive contract state when its time-to-live (TTL) reaches zero.
SoroRail's stateful contracts (`stream`, `vesting`, `escrow`, and `recurring`)
store one position in instance storage. Their shared storage helper renews that
instance and its code to 30 days whenever a mutating entry point loads or saves
state, and renews once fewer than 29 days remain.

Read-only calls deliberately do not extend TTL. They are safe to use for
polling without creating ledger writes or fees.

## Who calls `bump`

The application or operator responsible for a long-lived position must call
the public, permissionless `bump()` entry point before the instance expires.
This is normally the integrator's scheduler, wallet backend, or operations
service—not an end user and not a protocol keeper. Calling it requires no
business-role authorization, but the caller pays normal transaction fees.

Schedule it at least once every 28 days for inactive streams, grants, escrows,
and subscriptions. Normal writes (`withdraw`, `claim`, `fund`, or `charge`)
already renew TTL, so a separate call is needed only while activity is absent.

## Recovery and rollback

- If a contract is archived, restore its archival state through Stellar's
  restoration flow before invoking it; `bump()` cannot run until restored.
- A failed or retried `bump()` does not alter balances or lifecycle state, so
  it is safe to retry.
- `batch_payout` has no persisted position and therefore no `bump()` entry.

Constants and implementation live in `contracts/common/src/storage.rs`.
