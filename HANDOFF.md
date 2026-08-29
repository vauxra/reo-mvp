# REO handoff

## Azure verified

```text
Subscription: c6c9546a-a832-4543-9f6d-0e16d480936b
Resource group: reo-mvp
Location: resource group remains centralus; REO resources are recreated in eastus2 using Standard_D2s_v3 because Central US DSv5 quota is zero.
State: Succeeded
```

## Tools

Record: `docs/ops/tooling-state.md`

Installed for REO:

```text
Terraform 1.16.0
kubectl 1.37.0
kubelogin 0.2.19
Helm 4.2.4
```

## Built

```text
infra/                 Azure/Entra/AKS platform Terraform
infra/cluster/         Argo + Kubernetes RBAC Terraform
.github/workflows/     GitHub Actions OIDC submitter
examples/manifests/    one-off and cron Argo examples
examples/audit-review/ Log Analytics KQL review
reo.yaml               repo job declaration
```

## Test lane

```text
main push
-> GitHub Actions
-> GitHub OIDC Azure token
-> restricted AKS identity
-> Argo Workflow/CronWorkflow in reo-runs
-> 60-second pod cap
-> Log Analytics
```

No public endpoint. No GitHub secret. No GitHub App.

## Verified

```text
terraform -chdir=infra validate
passed

terraform -chdir=infra/cluster validate
passed

pytest
10 passed

YAML manifests
parsed
```

## Platform plan

Platform plan is regenerated before apply. Expected scope is nine new resources:

```text
Entra AKS admin group + current-user membership
Log Analytics workspace
VNet + subnet
AKS (one fixed D2s_v5 node)
GitHub Actions managed identity + OIDC federation
AKS Cluster User role assignment
```

No resource has been created by this session.

## Security gate before apply

Read: `docs/security/public-test-security-gate.md`

Accepted test boundary: only the owner can push `main`; formal GitHub branch/action policies are deferred.

Keep three zero/low-cost controls before apply: disable AKS local accounts, enforce `reo-runs` pod quotas, and disable job service-account token automount.

Those controls are now implemented and validated. Regenerate the platform plan before apply.

## Next

1. Regenerate and review platform plan.
2. Apply platform only.
3. Wait for Entra group membership propagation.
4. Plan/apply `infra/cluster`.
5. Set three GitHub Actions variables from `docs/ops/github-oidc-test.md`.
6. Commit/push test files, then run one-off and cron baseline.
7. Run KQL audit review.
