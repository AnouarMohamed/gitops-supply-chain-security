# Attack Scenarios

These scenarios turn the lab from a static manifest collection into a repeatable
security demonstration. The point is to show what the cluster refuses before a
bad workload can run.

Run the full suite:

```bash
make test-policies
make chainsaw-test
```

## Scenario Matrix

| Scenario | Fixture | Control | Expected result |
| --- | --- | --- | --- |
| Root container | `examples/violations/root-pod.yaml` | `disallow-root-user` | Denied |
| Mutable image tag | `examples/violations/latest-tag-pod.yaml` | `disallow-latest-tag` | Denied |
| No resource limits | `examples/violations/missing-limits-pod.yaml` | `require-resource-limits` | Denied |
| Untrusted Flask API image | `examples/violations/unsigned-flask-api-pod.yaml` | `verify-image-signature` | Denied |
| Clean non-root workload | `examples/allowed/non-root-limited-pod.yaml` | all runtime policies | Allowed |

## Root Container

The fixture sets `runAsUser: 0` and `runAsNonRoot: false`. Kyverno rejects it
because the lab requires a non-root runtime identity at either the Pod or
container level.

## Mutable Tag

The fixture uses `busybox:latest`. Kyverno rejects it because mutable tags hide
which image is really being deployed.

## Missing Limits

The fixture omits `resources.limits`. Kyverno rejects it because the staging
namespace is quota-aware and every container must have explicit CPU and memory
limits.

## Untrusted Flask API Image

The fixture references:

```text
ghcr.io/anouarmohamed/flask-api:unsigned-demo
```

Kyverno tries to verify it using the trusted GitHub Actions identity and denies
the request because the image reference is not signed by the expected workflow.

## Wrong GitHub Actions Identity

This is best shown by editing a local copy of `policy-verify-signature.yaml` and
changing the `subject` to a different workflow path or branch. A previously
trusted image will then fail verification because the signature identity no
longer matches policy.

Do not commit that change. It is a live demo variant.

## GitOps Drift

After the app is deployed, manually change a live resource:

```bash
kubectl -n stg scale deployment/flask-api --replicas=1
```

Argo CD self-healing should return the Deployment to the Git-declared state.
This demonstrates that drift is corrected by GitOps while unsafe workloads are
blocked by admission control.

## Evidence

Capture the scenario results in a report:

```bash
make evidence
```

The evidence report includes both the shell-based admission demo and the
Chainsaw policy suite.
