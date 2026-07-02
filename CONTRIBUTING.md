# Contributing

Keep this repo focused on the GitOps and supply-chain security extension for
`k8s-multiservice-lab`.

## Before Opening A Change

Run:

```bash
make validate
make verify-image
make verify-attestation
```

If the change touches policies or demo fixtures and you have a cluster
available, also run:

```bash
make apply-policies
make test-policies
make chainsaw-test
make evidence
```

## Change Guidelines

- Keep root manifests usable as direct `kubectl apply -f` entrypoints.
- Prefer small, explainable Kyverno policies over clever expressions.
- Keep demo resources in `examples/` and make expected failures obvious.
- Do not commit real secrets, kubeconfigs, registry tokens, or private keys.
- Update docs whenever workflow commands or trust identities change.
