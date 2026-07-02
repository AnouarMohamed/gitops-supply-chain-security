#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cluster

namespace="${NAMESPACE:-stg}"

section() {
  printf '\n## %s\n' "$1"
}

run() {
  "$@" || true
}

section "Context"
kubectl config current-context

section "Kyverno"
run kubectl -n kyverno get pods

section "ClusterPolicies"
run kubectl get clusterpolicy

section "Argo CD Application"
run kubectl -n argocd get applications.argoproj.io multiservice-app

section "Workloads: $namespace"
run kubectl -n "$namespace" get deploy,pod,svc,hpa,pdb

section "Recent Events: $namespace (last 20)"
events_file="$(mktemp)"
trap 'rm -f "$events_file"' EXIT

if kubectl -n "$namespace" get events --sort-by=.lastTimestamp >"$events_file" 2>/dev/null; then
  sed -n '1p' "$events_file"
  tail -n 20 "$events_file" | sed '/^LAST SEEN/d'
else
  warn "could not read events from namespace: $namespace"
fi
