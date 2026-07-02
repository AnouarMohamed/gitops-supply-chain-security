#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd kind
require_cmd kubectl

cluster_name="${CLUSTER_NAME:-supply-chain-lab}"

if kind get clusters | grep -Fxq "$cluster_name"; then
  info "kind cluster already exists: $cluster_name"
else
  info "creating kind cluster: $cluster_name"
  kind create cluster --name "$cluster_name" --config "$ROOT_DIR/kind-config.yaml"
fi

kubectl cluster-info --context "kind-$cluster_name"
info "current context: $(kubectl config current-context)"
