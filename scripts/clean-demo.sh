#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_cmd kubectl

namespace="${DEMO_NAMESPACE:-policy-lab-demo}"

kubectl delete namespace "$namespace" --ignore-not-found
