# REO Terraform

Two stacks. This avoids a Terraform bootstrap loop.

```text
infra/         Azure + Entra identity + AKS
infra/cluster/ Argo + namespace RBAC
```

## 1. Platform

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Platform creates one small fixed AKS node, Log Analytics, an AKS admin group, and GitHub Actions OIDC identity.

## 2. Cluster add-ons

Run only after platform apply and Entra group membership has propagated.

```bash
cd infra/cluster
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Cluster add-ons install Argo with server disabled, then give GitHub Actions permission only for `Workflow`/`CronWorkflow` in `reo-runs`.

No GitHub token, webhook, DNS, TLS, or public Argo endpoint.
