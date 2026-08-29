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

GitHub Actions run `33264073848` completed successfully on commit `7593866`. It checked out `main`, obtained a short-lived Azure OIDC token, acquired restricted AKS credentials, and submitted the REO examples.

## Audit log verification

The Azure Monitor agent is Terraform-managed through `container-azm-ms-agentconfig`: stdout/stderr from non-system namespaces is collected as `ContainerLogV2`; environment-variable collection is disabled. After the rolling agent restart and a new REO workflow, Log Analytics returned:

```text
TimeGenerated: 2026-08-29T16:51:36.0993055Z
PodName: reo-one-off-hello-wgdwr
ContainerName: main
LogMessage: REO_AUDIT_MARKER=one-off
```

Both platform and cluster Terraform plans now report no changes.

## Workbook

Terraform deployed **REO Run Operations** as `azurerm_application_insights_workbook.reo_runs`. It shows latest run state, `REO_HEARTBEAT` lines, pending/running pods older than 45 seconds, and raw execution logs. The workbook's heartbeat query was verified with `reo-one-off-hello-58j8s`:

```text
TimeGenerated: 2026-08-29T17:00:56.6711897Z
PodName: reo-one-off-hello-58j8s
ContainerName: main
LogMessage: REO_HEARTBEAT=one-off
```

Read `docs/ops/reo-workbook.md` for the portal location and redeploy instructions.

## Cleanup

```bash
az group delete --name reo-mvp --yes --no-wait
```
