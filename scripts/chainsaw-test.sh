#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cluster

chainsaw_bin="${CHAINSAW_BIN:-}"
if [[ -z "$chainsaw_bin" ]]; then
  if has_cmd chainsaw; then
    chainsaw_bin="$(command -v chainsaw)"
  else
    "$ROOT_DIR/scripts/install-chainsaw.sh"
    chainsaw_bin="$ROOT_DIR/.cache/bin/chainsaw"
  fi
fi

if ! kubectl get crd clusterpolicies.kyverno.io >/dev/null 2>&1; then
  die "Kyverno CRDs are missing. Run: make install-kyverno"
fi

info "applying policies before Chainsaw tests"
"$ROOT_DIR/scripts/apply-policies.sh" >/dev/null

info "running Chainsaw tests"
"$chainsaw_bin" test "$ROOT_DIR/chainsaw" --fail-fast --no-color --parallel 1 --quiet
