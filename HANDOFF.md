# REO handoff

## Deployed Azure state

```text
Subscription: c6c9546a-a832-4543-9f6d-0e16d480936b
Resource group: reo-mvp (metadata location centralus)
REO regional resources: eastus2
AKS: reo-mvp-aks
Node: one Standard_D2s_v3 node; autoscaling disabled
AKS local accounts: disabled
Argo Server: disabled; no public endpoint
```

## Security boundary

```text
GitHub Actions OIDC -> Entra user-assigned identity -> AKS Cluster User
GitHub subject: repo:vauxra@63472938/reo-mvp@1350685372:ref:refs/heads/main
Kubernetes submitter: Workflow/CronWorkflow only, namespace reo-runs
Workload service account: no token automount
Argo executor: separate token with workflowtaskresults create/patch only
```

## Verified runtime evidence

```text
one-off workflow: Succeeded
REO Python one-off passed
REO_AUDIT_MARKER=one-off

cron child workflow: Succeeded
REO Python cron passed
REO_AUDIT_MARKER=cron

cron schedule restored: 0 2 * * * UTC
```

## Validation

```text
terraform -chdir=infra validate: passed
terraform -chdir=infra/cluster validate: passed
python3 -m pytest tests -q: 6 passed
YAML manifests: parsed
```

## GitHub OIDC verification

The initial `main` push run (`33263459776`) failed before Kubernetes submission because this GitHub account emits an ID-qualified OIDC `sub`, while the first Entra federation used the legacy name-only form. Terraform has updated the Entra federation to the exact ID-qualified `main` subject. Push the pending correction commit to trigger and verify the end-to-end GitHub path.

## Audit log status

Container Insights inventory and metrics are present in Log Analytics. `ContainerLogV2` remains empty, so KQL workload-log confirmation is pending container-log collection configuration. Do not declare the audit path complete until `REO_AUDIT_MARKER` appears in `ContainerLogV2`.

## Cleanup

```bash
az group delete --name reo-mvp --yes --no-wait
```
