#!/usr/bin/env bash
# User tool — invocations signed by the investor / token holder.
# Usage: ./user-tool.sh <invest [amount]|balance|transfer [amount]|all>
# Override any variable below via env vars (e.g. USER_KEY=carol ./user-tool.sh balance).

set -euo pipefail

NETWORK="${NETWORK:-testnet}"
USER_KEY="${USER_KEY:-bob}"
CONTRACT_ID="${CONTRACT_ID:-CA42BHJ3P227BGMP4PHFOQTLCNJKWBHRH72A4ZTVVRWV4S5CUROL6BM2}"
RECIPIENT="${RECIPIENT:-G...RECIPIENT_PUBLIC_KEY...}"
INVESTOR="$(stellar keys address "$USER_KEY")"

invoke() {
  stellar contract invoke \
    --id "$CONTRACT_ID" \
    --source "$USER_KEY" \
    --network "$NETWORK" \
    -- \
    "$@"
}

invest() {
  # Variación: amounts below 500 payment-token units fail with AmountTooLow (#7).
  echo "=== invest $1 ==="
  invoke invest \
    --investor "$INVESTOR" \
    --payment_amount "$1"
}

balance() {
  echo "=== balance ==="
  invoke balance --id "$INVESTOR"
}

transfer() {
  echo "=== transfer $1 RWA tokens ==="
  invoke transfer \
    --from "$INVESTOR" \
    --to "$RECIPIENT" \
    --amount "$1"
}

case "${1:-}" in
  invest) invest "${2:-500}" ;;
  balance) balance ;;
  transfer) transfer "${2:-10}" ;;
  all) invest 500; balance; transfer 10 ;;
  *)
    echo "Usage: $0 <invest [amount]|balance|transfer [amount]|all>" >&2
    exit 1
    ;;
esac
