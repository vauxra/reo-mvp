import re
from pathlib import Path


def terraform_config() -> str:
    return "\n".join(path.read_text() for path in Path("infra").rglob("*.tf"))


def test_mvp_terraform_layout_has_platform_and_cluster_layers():
    for relative in (
        "versions.tf",
        "providers.tf",
        "variables.tf",
        "main.tf",
        "outputs.tf",
        "terraform.tfvars.example",
        "cluster/versions.tf",
        "cluster/providers.tf",
        "cluster/variables.tf",
        "cluster/main.tf",
    ):
        assert (Path("infra") / relative).is_file(), relative


def test_terraform_uses_github_oidc_not_webhooks_or_github_tokens():
    config = terraform_config()
    assert "github-actions" in config
    assert "https://token.actions.githubusercontent.com" in config
    assert re.search(
        r'subject\s*=\s*"repo:\$\{var\.github_owner\}@\$\{var\.github_owner_id\}/\$\{var\.github_repository\}@\$\{var\.github_repository_id\}:ref:refs/heads/main"',
        config,
    )
    assert "github_repository_webhook" not in config
    assert "github_token" not in config
    assert "azure_rbac_enabled" not in config or re.search(r"azure_rbac_enabled\s*=\s*false", config)
    assert 'resource "azuread_group" "aks_admins"' in config
    assert "aks_admin_group_object_id" not in config


def test_platform_has_no_kubernetes_or_helm_provider_bootstrap_loop():
    platform = "\n".join(path.read_text() for path in Path("infra").glob("*.tf"))
    assert 'provider "kubernetes"' not in platform
    assert 'provider "helm"' not in platform



def test_github_action_uses_oidc_and_applies_only_reo_manifests():
    workflow = Path(".github/workflows/reo-submit.yml").read_text()
    assert "id-token: write" in workflow
    assert "azure/login@" in workflow
    assert "kubelogin" in workflow
    assert "examples/manifests" in workflow


def test_mvp_has_local_account_and_job_resource_guardrails():
    platform = "\n".join(path.read_text() for path in Path("infra").glob("*.tf"))
    cluster = Path("infra/cluster/main.tf").read_text()
    one_off = Path("examples/manifests/one-off.yaml").read_text()
    cron = Path("examples/manifests/cron.yaml").read_text()

    assert re.search(r"local_account_disabled\s*=\s*true", platform)
    assert 'resource "kubernetes_resource_quota_v1" "reo_runs"' in cluster
    assert 'resource "kubernetes_limit_range_v1" "reo_runs"' in cluster
    assert "automountServiceAccountToken: false" in one_off
    assert "automountServiceAccountToken: false" in cron
    assert "serviceAccountName: reo-workflow" in one_off
    assert "serviceAccountName: reo-executor" in one_off
    assert "schedules:" in cron
    assert 'resource "kubernetes_service_account_v1" "reo_executor"' in cluster
    assert 'resource "kubernetes_secret_v1" "reo_executor_token"' in cluster
