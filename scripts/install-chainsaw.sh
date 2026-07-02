#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd curl
require_cmd tar
require_cmd sha256sum

version="${CHAINSAW_VERSION:-v0.2.15}"
version_number="${version#v}"
install_dir="${CHAINSAW_INSTALL_DIR:-$ROOT_DIR/.cache/bin}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

case "$(uname -s)" in
  Linux) os="linux" ;;
  Darwin) os="darwin" ;;
  *) die "unsupported OS for Chainsaw install: $(uname -s)" ;;
esac

case "$(uname -m)" in
  x86_64 | amd64) arch="amd64" ;;
  arm64 | aarch64) arch="arm64" ;;
  *) die "unsupported architecture for Chainsaw install: $(uname -m)" ;;
esac

asset="chainsaw_${os}_${arch}.tar.gz"
base_url="https://github.com/kyverno/chainsaw/releases/download/${version}"

mkdir -p "$install_dir"

if [[ -x "$install_dir/chainsaw" ]] && "$install_dir/chainsaw" version 2>/dev/null | grep -q "$version_number"; then
  info "Chainsaw already installed: $("$install_dir/chainsaw" version)"
  exit 0
fi

info "installing Chainsaw ${version} into ${install_dir}"
curl -fsSL -o "$tmp_dir/$asset" "$base_url/$asset"
curl -fsSL -o "$tmp_dir/checksums.txt" "$base_url/checksums.txt"

(
  cd "$tmp_dir"
  grep "  ${asset}$" checksums.txt | sha256sum -c -
)

tar -xzf "$tmp_dir/$asset" -C "$tmp_dir"
install -m 0755 "$tmp_dir/chainsaw" "$install_dir/chainsaw"

"$install_dir/chainsaw" version
