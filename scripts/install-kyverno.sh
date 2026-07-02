#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cluster
require_cmd helm

chart_args=()
if [[ -n "${KYVERNO_CHART_VERSION:-}" ]]; then
  chart_args+=(--version "$KYVERNO_CHART_VERSION")
fi

info "installing Kyverno"
helm repo add kyverno https://kyverno.github.io/kyverno/ >/dev/null
helm repo update kyverno >/dev/null
helm upgrade --install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace \
  --wait \
  "${chart_args[@]}"

kubectl -n kyverno rollout status deployment -l app.kubernetes.io/part-of=kyverno --timeout=180s || true
kubectl -n kyverno get pods
