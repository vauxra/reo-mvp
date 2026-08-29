# REO MVP

## Run path

```text
main push
-> GitHub Actions
-> GitHub OIDC short-lived Azure token
-> restricted AKS identity
-> Argo Workflow in reo-runs
-> short AKS pod
-> Log Analytics
```

## Cron path

```text
main push
-> GitHub Actions applies CronWorkflow
-> Argo cron fires
-> short AKS pod
-> Log Analytics
```

## Runtime cap

```text
Argo kills jobs after 60 seconds.
Keep 60s for the first baseline.
Raise only after measured examples need it.
```

## Auth

```text
No public Argo endpoint.
No GitHub webhook.
No GitHub token.

GitHub OIDC trust:
repo:vauxra/reo-mvp
ref: refs/heads/main

AKS RBAC:
Workflow/CronWorkflow only
namespace: reo-runs
```

## Examples

```text
examples/manifests/one-off.yaml
examples/manifests/cron.yaml
examples/audit-review/reo-audit.kql
```
