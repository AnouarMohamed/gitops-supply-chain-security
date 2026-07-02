# Demo Script

Use this as a concise live walkthrough.

## 30 Seconds: Positioning

This repo is the security extension to `k8s-multiservice-lab`. The app repo
proves Kubernetes delivery. This repo proves that delivery is controlled by
GitOps and protected by supply-chain admission checks.

## 2 Minutes: Show The Trust Chain

Open these files:

```text
argocd-app.yaml
policy-verify-signature.yaml
flask-api-sbom.json
```

Talk track:

- Argo CD deploys from the app repo staging overlay.
- Kyverno enforces runtime and supply-chain requirements at admission time.
- The Flask API image must be signed by the expected GitHub Actions workflow.
- The SBOM is evidence for what is inside the runtime image.

## 3 Minutes: Deploy And Inspect

```bash
make wait-app
make status
kubectl -n argocd get applications.argoproj.io
kubectl -n stg get deploy,pod,svc
kubectl get clusterpolicy
```

If starting from scratch:

```bash
make lab-up
```

## 3 Minutes: Deny Bad Workloads

```bash
make test-policies
make chainsaw-test
```

Explain each denial:

- root container: unsafe runtime identity
- latest tag: mutable image reference
- missing limits: uncontrolled resource usage
- unsigned Flask API image: provenance failure

Use `make chainsaw-test` to show the same controls packaged as declarative e2e
tests.

## 1 Minute: Evidence

```bash
make verify-image
make verify-attestation
make digest-reference
make sbom-summary
```

Close with the key point: the cluster does not trust a YAML file just because it
exists in Git. It checks runtime posture and image provenance before admission.

## 1 Minute: Evidence Report

```bash
make evidence
```

Open `reports/evidence.md`. This gives you a single artifact that captures the
live state, verified image digest, SBOM attestation, and policy denial results.
