#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cluster

namespace="${DEMO_NAMESPACE:-policy-lab-demo}"
failed=0

if ! kubectl get crd clusterpolicies.kyverno.io >/dev/null 2>&1; then
  die "Kyverno CRDs are missing. Run: make install-kyverno"
fi

kubectl get namespace "$namespace" >/dev/null 2>&1 || kubectl create namespace "$namespace"

cd "$ROOT_DIR"

info "allowed workload should pass server-side dry run"
kubectl -n "$namespace" apply --dry-run=server \
  -f "examples/allowed/non-root-limited-pod.yaml"

expect_deny() {
  local name="$1"
  local file="$2"
  local output

  if output="$(kubectl -n "$namespace" apply --dry-run=server -f "$file" 2>&1)"; then
    printf '[fail] %s was unexpectedly allowed\n' "$name" >&2
    printf '%s\n' "$output" >&2
    failed=1
  else
    printf '[pass] %s denied as expected\n' "$name"
    printf '%s\n' "$output" | sed -n '1,8p'
  fi
}

expect_deny "root container" "examples/violations/root-pod.yaml"
expect_deny "latest tag" "examples/violations/latest-tag-pod.yaml"
expect_deny "missing limits" "examples/violations/missing-limits-pod.yaml"
expect_deny "unsigned flask-api image" "examples/violations/unsigned-flask-api-pod.yaml"

if [[ "$failed" -ne 0 ]]; then
  die "one or more policy tests failed"
fi

info "policy tests passed"
