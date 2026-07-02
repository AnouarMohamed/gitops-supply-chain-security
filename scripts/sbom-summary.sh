#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd jq

sbom="${1:-$ROOT_DIR/flask-api-sbom.json}"

[[ -f "$sbom" ]] || die "SBOM not found: $sbom"

jq -r '
  def text($value): if $value == null or $value == "" then "unknown" else ($value | tostring) end;
  [
    "source: " + text(.source.name) + ":" + text(.source.version),
    "input: " + text(.source.metadata.userInput),
    "manifest: " + text(.source.metadata.manifestDigest),
    "repo digest: " + text(.source.metadata.repoDigests[0]),
    "image id: " + text(.source.metadata.imageID),
    "distro: " + text(.distro.prettyName),
    "scanner: " + text(.descriptor.name) + " " + text(.descriptor.version),
    "schema: " + text(.schema.version),
    "packages: " + text(.artifacts | length),
    "files: " + text(.files | length)
  ] | .[]
' "$sbom"
