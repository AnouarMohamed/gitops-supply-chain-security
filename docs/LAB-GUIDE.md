# Lab Guide

This guide assumes Docker is running and `kubectl` can talk to the cluster you
want to use. The fastest fully local path uses kind.

## Fast Path

Run the complete lab from a clean local machine:

```bash
make lab-up
make evidence
```

`make lab-up` creates the kind cluster, installs Kyverno and Argo CD, applies
the policies, deploys the app through Argo CD, waits for health, runs admission
tests, runs the Chainsaw suite, verifies the image signature, verifies the SBOM
attestation, prints the digest-pinned image reference, and summarizes the SBOM.

`make evidence` writes a live report to:

```text
reports/evidence.md
```

## 1. Check The Workstation

```bash
make doctor
```

Required tools:

- `kubectl`
- `jq`
- `python3`

Recommended tools for the full lab:

- `kind`
- `helm`
- `cosign`
- `syft`

## 2. Create A Local Cluster

```bash
make cluster-up
```

This creates a two-node kind cluster using `kind-config.yaml`.

```bash
kubectl get nodes
```

## 3. Install Kyverno

```bash
make install-kyverno
```

Confirm the controllers are ready:

```bash
kubectl -n kyverno get pods
```

## 4. Apply Admission Policies

```bash
make apply-policies
```

Expected policies:

```text
disallow-root-user
disallow-latest-tag
require-resource-limits
verify-image-signature
```

## 5. Install Argo CD

```bash
make install-argocd
```

For UI access:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

## 6. Deploy The App Through GitOps

```bash
make deploy-app
```

Argo CD reads the staging overlay from:

```text
https://github.com/AnouarMohamed/k8s-multiservice-lab.git
```

Inspect the deployment:

```bash
make wait-app
make status
kubectl -n stg get deploy,pod,svc,hpa,pdb
```

## 7. Run Admission Demos

```bash
make test-policies
make chainsaw-test
```

The script performs one allowed server-side dry run and several expected
denials:

- root container
- `:latest` image tag
- missing resource limits
- unsigned Flask API image reference

`make chainsaw-test` covers the same controls with Kyverno Chainsaw's
declarative test format.

## 8. Verify Evidence

```bash
make verify-image
make verify-attestation
make digest-reference
make sbom-summary
```

`verify-image` checks Sigstore keyless identity with Cosign.
`verify-attestation` verifies the SBOM attestation attached to the image.
`digest-reference` prints the digest-pinned image reference derived from the
verified signature. `sbom-summary` summarizes the checked-in Syft SBOM without
printing the full artifact.

## 9. Clean Demo Namespace

```bash
make clean-demo
```

To delete the whole local kind cluster:

```bash
make cluster-down
```
