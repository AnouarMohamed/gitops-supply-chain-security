SHELL := /usr/bin/env bash

CLUSTER_NAME ?= supply-chain-lab
NAMESPACE ?= stg
DEMO_NAMESPACE ?= policy-lab-demo
IMAGE ?= ghcr.io/anouarmohamed/flask-api:stg
REPORT_PATH ?= reports/evidence.md

.DEFAULT_GOAL := help

.PHONY: help validate doctor lab-up evidence cluster-up cluster-down install-kyverno install-argocd apply-policies deploy-app wait-app status test-policies verify-image verify-attestation digest-reference sbom-summary clean-demo

help:
	@printf 'GitOps Supply Chain Security Lab\n\n'
	@printf 'Targets:\n'
	@printf '  validate          Static validation for YAML, scripts, and SBOM shape\n'
	@printf '  doctor            Check required local tools and cluster access\n'
	@printf '  lab-up            Full local lab: cluster, controllers, policies, app, checks\n'
	@printf '  evidence          Generate a live evidence report in reports/evidence.md\n'
	@printf '  cluster-up        Create the local kind lab cluster\n'
	@printf '  cluster-down      Delete the local kind lab cluster\n'
	@printf '  install-kyverno   Install Kyverno with Helm\n'
	@printf '  install-argocd    Install Argo CD into the argocd namespace\n'
	@printf '  apply-policies    Apply all Kyverno ClusterPolicies\n'
	@printf '  deploy-app        Apply the Argo CD Application\n'
	@printf '  wait-app          Wait for Argo CD and app deployments to become healthy\n'
	@printf '  status            Show Argo CD, Kyverno, policy, and workload status\n'
	@printf '  test-policies     Run allowed and expected-denied admission dry runs\n'
	@printf '  verify-image      Verify the Flask API image signature with Cosign\n'
	@printf '  verify-attestation Verify the Flask API SBOM attestation with Cosign\n'
	@printf '  digest-reference  Print the verified digest-pinned image reference\n'
	@printf '  sbom-summary      Summarize the checked-in Syft SBOM\n'
	@printf '  clean-demo        Delete the policy demo namespace\n'

validate:
	./scripts/validate.sh

doctor:
	./scripts/doctor.sh

lab-up:
	CLUSTER_NAME="$(CLUSTER_NAME)" NAMESPACE="$(NAMESPACE)" DEMO_NAMESPACE="$(DEMO_NAMESPACE)" IMAGE="$(IMAGE)" ./scripts/lab-up.sh

evidence:
	REPORT_PATH="$(REPORT_PATH)" NAMESPACE="$(NAMESPACE)" DEMO_NAMESPACE="$(DEMO_NAMESPACE)" IMAGE="$(IMAGE)" ./scripts/generate-evidence.sh

cluster-up:
	CLUSTER_NAME="$(CLUSTER_NAME)" ./scripts/bootstrap-kind.sh

cluster-down:
	kind delete cluster --name "$(CLUSTER_NAME)"

install-kyverno:
	./scripts/install-kyverno.sh

install-argocd:
	./scripts/install-argocd.sh

apply-policies:
	./scripts/apply-policies.sh

deploy-app:
	./scripts/deploy-argocd-app.sh

wait-app:
	NAMESPACE="$(NAMESPACE)" ./scripts/wait-for-app.sh

status:
	NAMESPACE="$(NAMESPACE)" ./scripts/status.sh

test-policies:
	DEMO_NAMESPACE="$(DEMO_NAMESPACE)" ./scripts/policy-test.sh

verify-image:
	IMAGE="$(IMAGE)" ./scripts/verify-image-signature.sh

verify-attestation:
	IMAGE="$(IMAGE)" ./scripts/verify-image-attestation.sh

digest-reference:
	IMAGE="$(IMAGE)" ./scripts/digest-reference.sh

sbom-summary:
	./scripts/sbom-summary.sh

clean-demo:
	DEMO_NAMESPACE="$(DEMO_NAMESPACE)" ./scripts/clean-demo.sh
