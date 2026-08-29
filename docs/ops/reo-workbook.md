# REO Run Operations workbook

Terraform deploys the shared Azure Monitor workbook from `infra/workbook.tf`.

## Open it

In Azure Portal, open **Azure Monitor → Workbooks → REO Run Operations**. It is associated with the REO Log Analytics workspace.

Terraform resource ID:

```text
/subscriptions/c6c9546a-a832-4543-9f6d-0e16d480936b/resourceGroups/reo-mvp/providers/Microsoft.Insights/workbooks/e15341a9-bb4e-475d-9eb3-bf1b90d86d71
```

## Panels

- **Recent runs** — latest observed pod state per REO workflow pod.
- **Heartbeats** — lines containing `REO_HEARTBEAT`.
- **Long-running workloads** — `Running` or `Pending` pods older than 45 seconds. REO hard-stops workloads at 60 seconds.
- **Execution logs** — raw `ContainerLogV2` records for `reo-runs`.

## Heartbeat contract

Long-running workloads should write a line containing `REO_HEARTBEAT` at least every 10 seconds. The starter one-off and cron workloads each emit one heartbeat to prove the logging path.

## Redeploy

```bash
terraform -chdir=infra init
terraform -chdir=infra apply
```

The workbook uses a stable ID, the REO Log Analytics workspace as its source, and Terraform state. It is destroyed with the REO resource group cleanup.
