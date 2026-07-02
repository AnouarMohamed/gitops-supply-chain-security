#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd cosign
require_cmd jq

image="${IMAGE:-ghcr.io/anouarmohamed/flask-api:stg}"
issuer="${COSIGN_CERT_ISSUER:-https://token.actions.githubusercontent.com}"
identity="${COSIGN_CERT_IDENTITY:-https://github.com/AnouarMohamed/k8s-multiservice-lab/.github/workflows/build-sign-sbom.yml@refs/heads/main}"
attestations_file="$(mktemp)"
log_file="$(mktemp)"
trap 'rm -f "$attestations_file" "$log_file"' EXIT

info "verifying SBOM attestation: $image"
if ! cosign verify-attestation \
  --output json \
  --type spdxjson \
  --certificate-oidc-issuer "$issuer" \
  --certificate-identity "$identity" \
  "$image" >"$attestations_file" 2>"$log_file"; then
  cat "$log_file" >&2
  die "attestation verification failed"
fi

jq -sr '
  [
    .[]
    | (.payload | @base64d | fromjson) as $statement
    | {
        predicateType: $statement.predicateType,
        subjectName: $statement.subject[0].name,
        subjectDigest: $statement.subject[0].digest.sha256,
        created: $statement.predicate.creationInfo.created,
        creators: ($statement.predicate.creationInfo.creators // []),
        spdxId: $statement.predicate.SPDXID,
        packages: (($statement.predicate.packages // []) | length)
      }
  ]
  | unique_by(.subjectDigest, .predicateType)
  | .[]
  | "predicate: " + (.predicateType // "unknown"),
    "subject: " + (.subjectName // "unknown"),
    "digest: sha256:" + (.subjectDigest // "unknown"),
    "created: " + (.created // "unknown"),
    "spdx: " + (.spdxId // "unknown"),
    "packages: " + (.packages | tostring),
    "creators: " + ((.creators | join(", ")) // "unknown")
' "$attestations_file"
