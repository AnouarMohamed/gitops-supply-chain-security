#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd kind
require_cmd kubectl
require_cmd helm
require_cmd jq
require_cmd python3

if [[ "${SKIP_COSIGN:-0}" != "1" ]]; then
  require_cmd cosign
fi

info "starting full local lab"
"$ROOT_DIR/scripts/bootstrap-kind.sh"
"$ROOT_DIR/scripts/install-kyverno.sh"
"$ROOT_DIR/scripts/apply-policies.sh"
"$ROOT_DIR/scripts/install-argocd.sh"
"$ROOT_DIR/scripts/deploy-argocd-app.sh"
"$ROOT_DIR/scripts/wait-for-app.sh"

info "running policy admission demos"
"$ROOT_DIR/scripts/policy-test.sh"
"$ROOT_DIR/scripts/clean-demo.sh"

if [[ "${SKIP_COSIGN:-0}" != "1" ]]; then
  "$ROOT_DIR/scripts/verify-image-signature.sh"
  "$ROOT_DIR/scripts/verify-image-attestation.sh"
  "$ROOT_DIR/scripts/digest-reference.sh"
else
  warn "SKIP_COSIGN=1 set; skipping signature, attestation, and digest checks"
fi

"$ROOT_DIR/scripts/sbom-summary.sh"
"$ROOT_DIR/scripts/status.sh"

info "lab is ready"
