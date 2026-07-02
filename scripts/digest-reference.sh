#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd cosign
require_cmd jq

image="${IMAGE:-ghcr.io/anouarmohamed/flask-api:stg}"
issuer="${COSIGN_CERT_ISSUER:-https://token.actions.githubusercontent.com}"
identity="${COSIGN_CERT_IDENTITY:-https://github.com/AnouarMohamed/k8s-multiservice-lab/.github/workflows/build-sign-sbom.yml@refs/heads/main}"
output_file="$(mktemp)"
log_file="$(mktemp)"
trap 'rm -f "$output_file" "$log_file"' EXIT

if ! cosign verify \
  --output json \
  --certificate-oidc-issuer "$issuer" \
  --certificate-identity "$identity" \
  "$image" >"$output_file" 2>"$log_file"; then
  cat "$log_file" >&2
  die "could not verify image before deriving digest reference"
fi

jq -r --arg tag "$image" '
  .[0] as $signature
  | ($signature.critical.identity["docker-reference"] // ($tag | split(":")[0])) as $repository
  | ($signature.critical.image["docker-manifest-digest"] // "unknown") as $digest
  | "tag: " + $tag,
    "digest: " + $digest,
    "pinned: " + $repository + "@" + $digest
' "$output_file"
