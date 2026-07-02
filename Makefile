SHELL := /usr/bin/env bash

CLUSTER_NAME ?= supply-chain-lab
NAMESPACE ?= stg
DEMO_NAMESPACE ?= policy-lab-demo
IMAGE ?= ghcr.io/anouarmohamed/flask-api:stg

.DEFAULT_GOAL := help

.PHONY: help validate doctor cluster-up cluster-down install-kyverno install-argocd apply-policies deploy-app status test-policies verify-image sbom-summary clean-demo

help:
	@printf 'GitOps Supply Chain Security Lab\n\n'
	@printf 'Targets:\n'
	@printf '  validate          Static validation for YAML, scripts, and SBOM shape\n'
	@printf '  doctor            Check required local tools and cluster access\n'
	@printf '  cluster-up        Create the local kind lab cluster\n'
	@printf '  cluster-down      Delete the local kind lab cluster\n'
	@printf '  install-kyverno   Install Kyverno with Helm\n'
	@printf '  install-argocd    Install Argo CD into the argocd namespace\n'
	@printf '  apply-policies    Apply all Kyverno ClusterPolicies\n'
	@printf '  deploy-app        Apply the Argo CD Application\n'
	@printf '  status            Show Argo CD, Kyverno, policy, and workload status\n'
	@printf '  test-policies     Run allowed and expected-denied admission dry runs\n'
	@printf '  verify-image      Verify the Flask API image signature with Cosign\n'
	@printf '  sbom-summary      Summarize the checked-in Syft SBOM\n'
	@printf '  clean-demo        Delete the policy demo namespace\n'

validate:
	./scripts/validate.sh

doctor:
	./scripts/doctor.sh

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

status:
	NAMESPACE="$(NAMESPACE)" ./scripts/status.sh

test-policies:
	DEMO_NAMESPACE="$(DEMO_NAMESPACE)" ./scripts/policy-test.sh

verify-image:
	IMAGE="$(IMAGE)" ./scripts/verify-image-signature.sh

sbom-summary:
	./scripts/sbom-summary.sh

clean-demo:
	DEMO_NAMESPACE="$(DEMO_NAMESPACE)" ./scripts/clean-demo.sh
