# Chainsaw Tests

This repo includes Kyverno Chainsaw tests for the admission controls. Chainsaw
is a declarative Kubernetes e2e test runner maintained under the Kyverno
project.

## Install

```bash
make install-chainsaw
```

The installer pins Chainsaw to `v0.2.15`, downloads the platform binary from the
official Kyverno release, verifies the checksum, and installs it into:

```text
.cache/bin/chainsaw
```

## Run

```bash
make chainsaw-test
```

The runner:

1. checks that Kubernetes and Kyverno are available
2. applies the current policy manifests
3. runs `chainsaw test chainsaw --fail-fast --no-color --parallel 1 --quiet`

## Test Layout

```text
chainsaw/
├── allow-baseline/
├── disallow-latest/
├── disallow-root/
├── require-limits/
└── verify-signature/
```

Each directory contains a `chainsaw-test.yaml` file and reuses the fixtures in
`examples/allowed/` and `examples/violations/`.

## Why Keep Both Test Paths

`make test-policies` is concise and easy to read live. `make chainsaw-test`
packages the same expectations in a declarative e2e format that looks closer to
professional Kubernetes policy testing.

CI runs both.
