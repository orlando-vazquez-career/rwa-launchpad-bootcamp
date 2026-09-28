#!/usr/bin/env bash
# Admin tool — invocations that require the issuer/admin key to sign.
# Usage: ./admin-tool.sh <initialize|whitelist|mint|withdraw|pause|unpause|all>
# Override any variable below via env vars (e.g. CONTRACT_ID=C... ./admin-tool.sh initialize).

set -euo pipefail

NETWORK="${NETWORK:-testnet}"
ADMIN_KEY="${ADMIN_KEY:-alice}"
CONTRACT_ID="${CONTRACT_ID:-CALMIZEWORJQHR2G3354L255YLQ42JMV22LALN43EKBMSWFPTJWA7KEE}"
# Native XLM Stellar Asset Contract on testnet.
PAYMENT_TOKEN="${PAYMENT_TOKEN:-CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC}"
INVESTOR="${INVESTOR:-$(stellar keys address "${USER_KEY:-bob}")}"
ADMIN="$(stellar keys address "$ADMIN_KEY")"
TREASURY="${TREASURY:-$ADMIN}"

invoke() {
  stellar contract invoke \
    --id "$CONTRACT_ID" \
    --source "$ADMIN_KEY" \
    --network "$NETWORK" \
    -- \
    "$@"
}

initialize() {
  echo "=== initialize (run once after deploy) ==="
  invoke initialize \
    --admin "$ADMIN" \
    --asset '{"name":"RWAToken","total_supply":"1000000","price_per_unit":"100","payment_token":"'"$PAYMENT_TOKEN"'","paused":false}'
}

whitelist() {
  echo "=== set_whitelist ==="
  invoke set_whitelist \
    --admin "$ADMIN" \
    --investor "$INVESTOR" \
    --approved true
}

mint() {
  echo "=== mint (admin-only; optional if using invest) ==="
  invoke mint \
    --admin "$ADMIN" \
    --to "$INVESTOR" \
    --amount 100
}

withdraw() {
  echo "=== withdraw collected payment tokens ==="
  invoke withdraw \
    --admin "$ADMIN" \
    --to "$TREASURY" \
    --amount 500
}

pause() {
  echo "=== pause ==="
  invoke pause --admin "$ADMIN"
}

unpause() {
  echo "=== unpause ==="
  invoke unpause --admin "$ADMIN"
}

case "${1:-}" in
  initialize) initialize ;;
  whitelist) whitelist ;;
  mint) mint ;;
  withdraw) withdraw ;;
  pause) pause ;;
  unpause) unpause ;;
  all) initialize; whitelist; mint; withdraw; pause; unpause ;;
  *)
    echo "Usage: $0 <initialize|whitelist|mint|withdraw|pause|unpause|all>" >&2
    exit 1
    ;;
esac
