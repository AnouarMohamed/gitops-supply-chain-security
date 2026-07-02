#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() {
  printf '[info] %s\n' "$*"
}

warn() {
  printf '[warn] %s\n' "$*" >&2
}

die() {
  printf '[error] %s\n' "$*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

require_cmd() {
  local cmd="$1"

  if ! has_cmd "$cmd"; then
    die "missing required command: $cmd"
  fi
}

require_cluster() {
  require_cmd kubectl

  if ! kubectl cluster-info >/dev/null 2>&1; then
    die "kubectl cannot reach a Kubernetes cluster"
  fi
}
