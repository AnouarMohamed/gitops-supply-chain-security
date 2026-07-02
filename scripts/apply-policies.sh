#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cluster

if ! kubectl get crd clusterpolicies.kyverno.io >/dev/null 2>&1; then
  die "Kyverno CRDs are missing. Run: make install-kyverno"
fi

info "applying Kyverno policies"
kubectl apply -f "$ROOT_DIR/policy-no-root.yaml"
kubectl apply -f "$ROOT_DIR/policy-no-latest-tag.yaml"
kubectl apply -f "$ROOT_DIR/policy-require-limits.yaml"
kubectl apply -f "$ROOT_DIR/policy-verify-signature.yaml"

kubectl get clusterpolicy
