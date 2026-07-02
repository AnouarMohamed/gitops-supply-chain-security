# Chainsaw Policy Tests

These tests use Kyverno Chainsaw to exercise the same admission controls as
`make test-policies`, but in a declarative Kubernetes e2e test format.

Run:

```bash
make chainsaw-test
```

The test runner applies the current Kyverno policies first, then runs every
`chainsaw-test.yaml` under this directory.

## Test Matrix

| Test | Fixture | Expected result |
| --- | --- | --- |
| `allow-baseline` | `examples/allowed/non-root-limited-pod.yaml` | Accepted |
| `disallow-root` | `examples/violations/root-pod.yaml` | Denied |
| `disallow-latest` | `examples/violations/latest-tag-pod.yaml` | Denied |
| `require-limits` | `examples/violations/missing-limits-pod.yaml` | Denied |
| `verify-signature` | `examples/violations/unsigned-flask-api-pod.yaml` | Denied |
