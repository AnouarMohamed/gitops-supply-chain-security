# Policy Controls

The Kyverno policies are intentionally small enough to teach clearly, but each
one maps to a real production control.

| Policy | File | Admission result |
| --- | --- | --- |
| Disallow root containers | `policy-no-root.yaml` | Enforce |
| Disallow `:latest` image tags | `policy-no-latest-tag.yaml` | Enforce |
| Require CPU and memory limits | `policy-require-limits.yaml` | Enforce |
| Verify Flask API image signature | `policy-verify-signature.yaml` | Enforce |

## Runtime Controls

### `disallow-root-user`

Requires Pods to declare a non-root runtime at the Pod or container level. The
app workload already satisfies this through its Deployment security contexts.
The policy makes that expectation cluster-enforced without forcing duplicate
settings into every container.

### `disallow-latest-tag`

Blocks images that explicitly use `:latest`. Mutable tags make rollbacks,
forensics, and provenance verification harder. The app lab uses the stable
`stg` tag for local presentation and signs that tag in the app workflow.

For production, prefer immutable image digests plus Git-based image updates.

### `require-resource-limits`

Requires every container to define CPU and memory limits. This keeps the staging
namespace compatible with quota and makes noisy-neighbor behavior visible during
the lab.

## Supply Chain Control

### `verify-image-signature`

Verifies `ghcr.io/anouarmohamed/flask-api:*` with Sigstore keyless identity. The
trusted identity is the app repo workflow:

```text
https://github.com/AnouarMohamed/k8s-multiservice-lab/.github/workflows/build-sign-sbom.yml@refs/heads/main
```

This is the most important control in the lab. A user can write a valid Pod with
the correct resource limits and non-root settings, but Kyverno still denies it
if the Flask API image was not signed by the expected workflow identity.

## Demo Resources

Positive and negative resources live in `examples/`:

```text
examples/allowed/non-root-limited-pod.yaml
examples/violations/root-pod.yaml
examples/violations/latest-tag-pod.yaml
examples/violations/missing-limits-pod.yaml
examples/violations/unsigned-flask-api-pod.yaml
```

Run them with:

```bash
make test-policies
```

The script uses Kubernetes server-side dry runs, so successful demos do not
leave Pods running in the cluster.
