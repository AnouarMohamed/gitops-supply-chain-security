#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cluster

namespace="${NAMESPACE:-stg}"
attempts="${ARGOCD_WAIT_ATTEMPTS:-90}"
sleep_seconds="${ARGOCD_WAIT_SLEEP:-5}"

info "waiting for Argo CD Application multiservice-app"
for ((attempt = 1; attempt <= attempts; attempt++)); do
  sync_status="$(kubectl -n argocd get applications.argoproj.io multiservice-app -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health_status="$(kubectl -n argocd get applications.argoproj.io multiservice-app -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

  if [[ "$sync_status" == "Synced" && "$health_status" == "Healthy" ]]; then
    info "Argo CD Application is Synced and Healthy"
    break
  fi

  if [[ "$attempt" -eq "$attempts" ]]; then
    kubectl -n argocd get applications.argoproj.io multiservice-app -o yaml || true
    die "Argo CD Application did not become Synced/Healthy"
  fi

  printf '[info] waiting: sync=%s health=%s\n' "${sync_status:-unknown}" "${health_status:-unknown}"
  sleep "$sleep_seconds"
done

info "waiting for app deployments in namespace: $namespace"
kubectl -n "$namespace" rollout status deployment/redis --timeout=180s
kubectl -n "$namespace" rollout status deployment/flask-api --timeout=240s
