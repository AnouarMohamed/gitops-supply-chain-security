# Troubleshooting

## `kubectl` Cannot Reach The Cluster

Check the current context:

```bash
kubectl config current-context
kubectl get nodes
```

For the local lab:

```bash
make cluster-up
kubectl config use-context kind-supply-chain-lab
```

## Kyverno CRDs Are Missing

If `make apply-policies` fails with unknown `ClusterPolicy`, install Kyverno:

```bash
make install-kyverno
```

Then retry:

```bash
make apply-policies
```

## Argo CD Application CRD Is Missing

If `make deploy-app` fails with unknown `Application`, install Argo CD:

```bash
make install-argocd
```

Then retry:

```bash
make deploy-app
```

## Signature Verification Times Out

The signature policy calls external Sigstore and registry services. Check:

```bash
kubectl -n kyverno logs deploy/kyverno-admission-controller --tail=100
kubectl -n kyverno get pods
```

Common causes:

- the cluster cannot reach GHCR or Rekor
- the image tag was not signed by the expected workflow identity
- the policy subject does not match the workflow path or branch

## Argo CD Is Healthy But The App Is Not Running

Inspect the app namespace:

```bash
kubectl -n stg get events --sort-by=.lastTimestamp
kubectl -n stg describe deploy/flask-api
kubectl -n stg describe pod -l app.kubernetes.io/name=flask-api
```

If admission blocked a Pod, the event message should reference a Kyverno policy.

## HPA Shows Unknown CPU Metrics

Local kind clusters do not install `metrics-server` by default. If `make status`
shows an HPA warning such as `pods.metrics.k8s.io` not found, the app can still
be healthy. Install metrics-server only if you want to demonstrate autoscaling.

## Policy Demo Namespace Is Left Behind

The policy tests use server-side dry runs, but they create a namespace for
realistic admission checks. Remove it with:

```bash
make clean-demo
```
