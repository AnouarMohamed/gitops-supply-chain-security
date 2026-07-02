# Digest Pinning

The lab deploys `ghcr.io/anouarmohamed/flask-api:stg` because it keeps the
presentation simple and matches the app repo workflow. The next production step
is digest pinning.

## Tag Reference

```text
ghcr.io/anouarmohamed/flask-api:stg
```

Tags are convenient, but they are mutable. The bytes behind the tag can change.

## Digest Reference

```bash
make digest-reference
```

The command verifies the image signature first, then prints a pinned reference:

```text
ghcr.io/anouarmohamed/flask-api@sha256:<digest>
```

Digest references are immutable. They make rollbacks, audits, and incident
response easier because every deployment points to exact image bytes.

## Presentation Point

Use this sequence:

1. Show the Argo CD Application deploying the staging overlay.
2. Run `make verify-image` to prove the tag is signed by the expected workflow.
3. Run `make digest-reference` to show the immutable digest behind the tag.
4. Explain that a stricter production setup would commit the digest reference
   into Git and let Argo CD deploy only immutable artifacts.

## Production Variant

In the app repo overlay, replace:

```yaml
images:
  - name: flask-api
    newName: ghcr.io/anouarmohamed/flask-api
    newTag: stg
```

with a digest-based patch or image update flow that produces:

```text
ghcr.io/anouarmohamed/flask-api@sha256:<digest>
```

Then remove the Argo CD `ignoreDifferences` rule for the API image if Git should
be the only source of image changes.
