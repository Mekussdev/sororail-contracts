# Invoking SoroRail contracts with the Stellar CLI

These templates use the current `stellar` CLI. Replace every placeholder with
your testnet contract, token, and account address before running them.

```bash
export NETWORK=testnet
export STREAM_ID=CA...; export VESTING_ID=CA...; export ESCROW_ID=CA...
export RECURRING_ID=CA...; export BATCH_PAYOUT_ID=CA...; export TOKEN_ID=CA...
export SENDER=G...; export RECIPIENT=G...; export FUNDER=G...
export BENEFICIARY=G...; export ARBITER=G...; export PAYEE=G...
```

Time parameters are UNIX timestamps. `--source-account` refers to a configured
CLI identity and prompts it to sign.

## Stream

```bash
stellar contract invoke --network "$NETWORK" --source-account sender --id "$STREAM_ID" -- create --sender "$SENDER" --recipient "$RECIPIENT" --token "$TOKEN_ID" --rate_per_second 100 --start 1760000000 --stop 1760003600 --cancellable true
stellar contract invoke --network "$NETWORK" --source-account recipient --id "$STREAM_ID" -- withdraw --amount 100
stellar contract invoke --network "$NETWORK" --id "$STREAM_ID" -- bump
```

## Vesting

```bash
stellar contract invoke --network "$NETWORK" --source-account funder --id "$VESTING_ID" -- create --grantor "$FUNDER" --beneficiary "$BENEFICIARY" --token "$TOKEN_ID" --total 1000000 --start 1760000000 --cliff 0 --duration 2592000 --revocable true
stellar contract invoke --network "$NETWORK" --source-account beneficiary --id "$VESTING_ID" -- claim
stellar contract invoke --network "$NETWORK" --id "$VESTING_ID" -- schedule
stellar contract invoke --network "$NETWORK" --id "$VESTING_ID" -- bump
```

## Escrow

```bash
stellar contract invoke --network "$NETWORK" --source-account funder --id "$ESCROW_ID" -- init --depositor "$FUNDER" --beneficiary "$BENEFICIARY" --arbiter "$ARBITER" --token "$TOKEN_ID" --amount 500000 --deadline 1760600000
stellar contract invoke --network "$NETWORK" --source-account funder --id "$ESCROW_ID" -- fund
stellar contract invoke --network "$NETWORK" --source-account funder --id "$ESCROW_ID" -- release --caller "$FUNDER"
stellar contract invoke --network "$NETWORK" --id "$ESCROW_ID" -- bump
```

Use `--arbiter null` for an escrow without an arbiter. `resolve` is only valid
after `dispute` and is signed by the stored arbiter.

## Recurring

```bash
stellar contract invoke --network "$NETWORK" --source-account sender --id "$RECURRING_ID" -- authorize --payer "$SENDER" --payee "$PAYEE" --token "$TOKEN_ID" --amount_per_period 1000 --period_seconds 2592000 --max_periods 12
stellar contract invoke --network "$NETWORK" --source-account payee --id "$RECURRING_ID" -- charge
stellar contract invoke --network "$NETWORK" --id "$RECURRING_ID" -- bump
```

Before `charge`, the payer must approve the recurring contract as a token
spender. Removing that allowance or calling `cancel` stops future charges.

## Batch payout

`batch_payout` is stateless, so it has no `bump` entry point.

```bash
stellar contract invoke --network "$NETWORK" --source-account funder --id "$BATCH_PAYOUT_ID" -- execute_equal --funder "$FUNDER" --token "$TOKEN_ID" --recipients '["GRECIPIENT_ONE...","GRECIPIENT_TWO..."]' --amount_each 2500
stellar contract invoke --network "$NETWORK" --id "$BATCH_PAYOUT_ID" -- max_recipients
```

For different amounts, use `execute` or `preview` with a JSON list of
`Payment` values from the generated interface. Inspect the deployed ABI with
`stellar contract info interface --wasm <file>` before scripting production.
