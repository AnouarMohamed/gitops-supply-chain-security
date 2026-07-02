# Evidence

This repo keeps a local evidence artifact for the Flask API image:

```text
flask-api-sbom.json
```

The file is Syft native JSON. It records package inventory, file metadata,
image configuration, layers, distro metadata, and scanner metadata.

## Summarize The SBOM

```bash
make sbom-summary
```

Expected fields include:

- source image name and version
- manifest digest
- image ID
- distro
- Syft version
- package count
- file count

## Verify Image Signature

```bash
make verify-image
```

The verification command checks:

```text
image:   ghcr.io/anouarmohamed/flask-api:stg
issuer:  https://token.actions.githubusercontent.com
subject: https://github.com/AnouarMohamed/k8s-multiservice-lab/.github/workflows/build-sign-sbom.yml@refs/heads/main
```

## Verify SBOM Attestation

```bash
make verify-attestation
```

This verifies the `spdxjson` attestation attached to the image and prints a
concise summary of the in-toto statement: predicate type, subject digest,
creation time, SPDX document ID, package count, and creator.

## Generate A Live Evidence Report

```bash
make evidence
```

The generated report is written to:

```text
reports/evidence.md
```

It captures:

- Argo CD sync and health
- Kyverno policy readiness
- staging workloads
- live Flask API image digest and Kyverno verification annotation
- image signature verification
- SBOM attestation verification
- digest-pinned image reference
- checked-in SBOM summary
- admission policy demo results
- Chainsaw policy test results

## Evidence Story For Presentation

Use this sequence:

1. Show the app repo workflow that builds, signs, and generates SBOM evidence.
2. Show `policy-verify-signature.yaml` and the GitHub Actions identity bound in
   the policy.
3. Run `make verify-image`.
4. Run `make verify-attestation`.
5. Run `make digest-reference`.
6. Run `make sbom-summary`.
7. Run `make test-policies` and show that unsigned image references are denied.
8. Run `make chainsaw-test` to show the same controls in declarative e2e tests.

That gives a clean supply-chain narrative: build provenance, registry artifact,
signature verification, SBOM evidence, and cluster admission enforcement.
