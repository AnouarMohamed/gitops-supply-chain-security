# Security Policy

This is a lab repository. Do not use its example tokens, namespace names, or
installation defaults as production secrets or production policy.

## Reporting Issues

For security-sensitive issues, open a private report through GitHub if the
repository has private vulnerability reporting enabled. Otherwise contact the
repository owner directly before publishing details.

## Lab Boundaries

- The checked-in SBOM is demonstration evidence for the Flask API image.
- The Argo CD Application targets the public staging overlay in
  `AnouarMohamed/k8s-multiservice-lab`.
- The Kyverno signature policy trusts a specific GitHub Actions workflow
  identity from that app repo.
- Real production environments should pin images by digest, use environment
  specific policy exceptions, and manage secrets through a dedicated secrets
  system.
