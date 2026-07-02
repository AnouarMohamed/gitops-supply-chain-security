#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd date
require_cmd git
require_cmd jq
require_cmd kubectl

report="${REPORT_PATH:-$ROOT_DIR/reports/evidence.md}"
namespace="${NAMESPACE:-stg}"
demo_namespace="${DEMO_NAMESPACE:-policy-lab-demo}"
image="${IMAGE:-ghcr.io/anouarmohamed/flask-api:stg}"

mkdir -p "$(dirname "$report")"

run_block() {
  local title="$1"
  shift

  printf '## %s\n\n' "$title"
  printf '```text\n'
  set +e
  "$@" 2>&1
  local status=$?
  set -e
  printf '```\n\n'
  if [[ "$status" -ne 0 ]]; then
    printf '_Command exited with status %s._\n\n' "$status"
  fi
}

write_runtime_image() {
  printf '## Runtime Image\n\n'
  printf '```text\n'
  kubectl -n "$namespace" get deployment flask-api \
    -o jsonpath='image: {.spec.template.spec.containers[0].image}{"\n"}verify-images: {.metadata.annotations.kyverno\.io/verify-images}{"\n"}' 2>&1 || true
  printf '```\n\n'
}

{
  printf '# GitOps Supply Chain Security Evidence\n\n'
  printf 'Generated: `%s`\n\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  printf 'Repository: `%s`\n\n' "$(git config --get remote.origin.url || true)"
  printf 'Commit: `%s`\n\n' "$(git rev-parse HEAD)"
  printf 'Image: `%s`\n\n' "$image"

  run_block "Argo CD Application" kubectl -n argocd get applications.argoproj.io multiservice-app -o wide
  run_block "Kyverno Policies" kubectl get clusterpolicy
  run_block "Workloads" kubectl -n "$namespace" get deploy,pod,svc,hpa,pdb
  write_runtime_image
  run_block "Image Signature Verification" "$ROOT_DIR/scripts/verify-image-signature.sh"
  run_block "SBOM Attestation Verification" "$ROOT_DIR/scripts/verify-image-attestation.sh"
  run_block "Digest-Pinned Reference" "$ROOT_DIR/scripts/digest-reference.sh"
  run_block "Checked-In SBOM Summary" "$ROOT_DIR/scripts/sbom-summary.sh"
  run_block "Admission Policy Demo" env DEMO_NAMESPACE="$demo_namespace" "$ROOT_DIR/scripts/policy-test.sh"
  run_block "Demo Namespace Cleanup" env DEMO_NAMESPACE="$demo_namespace" "$ROOT_DIR/scripts/clean-demo.sh"
} >"$report"

info "wrote evidence report: $report"
