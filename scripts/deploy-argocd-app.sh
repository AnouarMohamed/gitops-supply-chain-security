#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cluster

if ! kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  die "Argo CD Application CRD is missing. Run: make install-argocd"
fi

kubectl get namespace argocd >/dev/null 2>&1 || kubectl create namespace argocd

info "applying Argo CD Application"
kubectl apply -f "$ROOT_DIR/argocd-app.yaml"

kubectl -n argocd get applications.argoproj.io multiservice-app
