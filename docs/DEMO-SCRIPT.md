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
make status
kubectl -n argocd get applications.argoproj.io
kubectl -n stg get deploy,pod,svc
kubectl get clusterpolicy
```

If starting from scratch:

```bash
make cluster-up
make install-kyverno
make apply-policies
make install-argocd
make deploy-app
```

## 3 Minutes: Deny Bad Workloads

```bash
make test-policies
```

Explain each denial:

- root container: unsafe runtime identity
- latest tag: mutable image reference
- missing limits: uncontrolled resource usage
- unsigned Flask API image: provenance failure

## 1 Minute: Evidence

```bash
make verify-image
make sbom-summary
```

Close with the key point: the cluster does not trust a YAML file just because it
exists in Git. It checks runtime posture and image provenance before admission.
