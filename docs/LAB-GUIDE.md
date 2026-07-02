# Lab Guide

This guide assumes Docker is running and `kubectl` can talk to the cluster you
want to use. The fastest fully local path uses kind.

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
make status
kubectl -n stg get deploy,pod,svc,hpa,pdb
```

## 7. Run Admission Demos

```bash
make test-policies
```

The script performs one allowed server-side dry run and several expected
denials:

- root container
- `:latest` image tag
- missing resource limits
- unsigned Flask API image reference

## 8. Verify Evidence

```bash
make verify-image
make sbom-summary
```

`verify-image` checks Sigstore keyless identity with Cosign. `sbom-summary`
summarizes the checked-in Syft SBOM without printing the full artifact.

## 9. Clean Demo Namespace

```bash
make clean-demo
```

To delete the whole local kind cluster:

```bash
make cluster-down
```
