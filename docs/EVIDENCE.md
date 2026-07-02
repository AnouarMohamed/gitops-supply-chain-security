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

## Evidence Story For Presentation

Use this sequence:

1. Show the app repo workflow that builds, signs, and generates SBOM evidence.
2. Show `policy-verify-signature.yaml` and the GitHub Actions identity bound in
   the policy.
3. Run `make verify-image`.
4. Run `make sbom-summary`.
5. Run `make test-policies` and show that unsigned image references are denied.

That gives a clean supply-chain narrative: build provenance, registry artifact,
signature verification, SBOM evidence, and cluster admission enforcement.
