#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ci_mode=0
if [[ "${1:-}" == "--ci" ]]; then
  ci_mode=1
fi

missing=0
required=(python3 jq)

if [[ "$ci_mode" -eq 0 ]]; then
  required+=(kubectl)
fi

optional=(kind helm cosign syft chainsaw argocd kyverno grype yq shellcheck)

info "checking required tools"
for cmd in "${required[@]}"; do
  if has_cmd "$cmd"; then
    printf '  ok      %s (%s)\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '  missing %s\n' "$cmd"
    missing=1
  fi
done

info "checking optional tools"
for cmd in "${optional[@]}"; do
  if has_cmd "$cmd"; then
    printf '  ok      %s (%s)\n' "$cmd" "$(command -v "$cmd")"
  elif [[ "$cmd" == "chainsaw" && -x "$ROOT_DIR/.cache/bin/chainsaw" ]]; then
    printf '  ok      %s (%s)\n' "$cmd" "$ROOT_DIR/.cache/bin/chainsaw"
  else
    printf '  optional-missing %s\n' "$cmd"
  fi
done

if ! python3 - <<'PY' >/dev/null 2>&1
import yaml
PY
then
  warn "Python package PyYAML is missing; install it to run make validate"
  missing=1
fi

info "checking required lab files"
for file in \
  argocd-app.yaml \
  kind-config.yaml \
  policy-no-root.yaml \
  policy-no-latest-tag.yaml \
  policy-require-limits.yaml \
  policy-verify-signature.yaml \
  flask-api-sbom.json; do
  if [[ -f "$ROOT_DIR/$file" ]]; then
    printf '  ok      %s\n' "$file"
  else
    printf '  missing %s\n' "$file"
    missing=1
  fi
done

if [[ "$ci_mode" -eq 0 ]] && has_cmd kubectl; then
  info "checking Kubernetes context"
  if kubectl cluster-info >/dev/null 2>&1; then
    printf '  context %s\n' "$(kubectl config current-context)"
  else
    warn "kubectl is installed but no reachable cluster was found"
  fi
fi

if [[ "$missing" -ne 0 ]]; then
  die "doctor checks failed"
fi

info "doctor checks passed"
