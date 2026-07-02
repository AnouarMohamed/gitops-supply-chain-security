#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd bash
require_cmd jq
require_cmd python3

info "checking shell syntax"
while IFS= read -r file; do
  bash -n "$file"
  printf '  ok %s\n' "$file"
done < <(find "$ROOT_DIR/scripts" -type f -name '*.sh' | sort)

info "validating YAML files"
mapfile -t yaml_files < <(
  find "$ROOT_DIR" \
    -path "$ROOT_DIR/.git" -prune -o \
    -type f \( -name '*.yaml' -o -name '*.yml' \) -print | sort
)

python3 "$ROOT_DIR/scripts/validate_yaml.py" "${yaml_files[@]}"

info "validating SBOM shape"
jq -e '.artifacts and .descriptor and .source and .schema' \
  "$ROOT_DIR/flask-api-sbom.json" >/dev/null

"$ROOT_DIR/scripts/sbom-summary.sh" >/dev/null

info "static validation passed"
