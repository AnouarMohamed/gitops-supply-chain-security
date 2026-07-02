#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd cosign
require_cmd jq

image="${IMAGE:-ghcr.io/anouarmohamed/flask-api:stg}"
issuer="${COSIGN_CERT_ISSUER:-https://token.actions.githubusercontent.com}"
identity="${COSIGN_CERT_IDENTITY:-https://github.com/AnouarMohamed/k8s-multiservice-lab/.github/workflows/build-sign-sbom.yml@refs/heads/main}"
output_file="$(mktemp)"
trap 'rm -f "$output_file"' EXIT

info "verifying image signature: $image"
cosign verify \
  --output json \
  --certificate-oidc-issuer "$issuer" \
  --certificate-identity "$identity" \
  "$image" >"$output_file"

jq -r '
  [
    .[] | {
      digest: .critical.image["docker-manifest-digest"],
      issuer: .optional.Issuer,
      subject: .optional.Subject,
      workflow: .optional.githubWorkflowName,
      repository: .optional.githubWorkflowRepository,
      ref: .optional.githubWorkflowRef,
      sha: .optional.githubWorkflowSha
    }
  ] | unique | .[] |
  "digest: " + (.digest // "unknown"),
  "issuer: " + (.issuer // "unknown"),
  "subject: " + (.subject // "unknown"),
  "workflow: " + (.repository // "unknown") + " / " + (.workflow // "unknown"),
  "ref: " + (.ref // "unknown"),
  "sha: " + (.sha // "unknown")
' "$output_file"
