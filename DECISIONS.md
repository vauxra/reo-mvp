# REO decisions

## Product

REO = Relic Execution Orchestrator.

## Test MVP

- Public test repository: `vauxra/reo-mvp`.
- Argo Workflows on AKS.
- Terraform deploys Azure, Entra identity, Argo, and Kubernetes RBAC.
- GitHub Actions runs on protected `main` push or manual dispatch.
- GitHub Actions OIDC gets a short-lived Azure token.
- GitHub identity submits Argo `Workflow` and `CronWorkflow` only in `reo-runs`.
- Argo Server is disabled. No public Argo endpoint.
- Argo uses `activeDeadlineSeconds: 60`.
- Platform region: `eastus2`; existing resource group remains Central US.
- Node: `Standard_D2s_v3` because Central US and West US 2 DSv5 quota is zero; East US 2 has available Dv3 quota and unrestricted SKU availability.
- Basic platform only: VNet, AKS, Log Analytics, Entra group/identity.
- Log Analytics daily ingestion cap: 0.5 GB.

## Auth boundary

- No GitHub App, PAT, webhook, DNS, or TLS needed for this test.
- Entra federation trusts only `repo:vauxra/reo-mvp:ref:refs/heads/main`.
- GitHub identity has AKS Cluster User access.
- Kubernetes RoleBinding limits it to Argo `Workflow`/`CronWorkflow` API resources in `reo-runs`.
- Owner-only `main` is the accepted test trust boundary; formal GitHub branch/action policies are deferred.
- AKS local accounts stay disabled; `reo-runs` gets pod quotas and job pods do not receive service-account tokens.

## Runtime baseline

- Argo hard-kills at 60 seconds.
- Run one-off and cron examples first.
- Raise cap only after observed logs show 60 seconds is too short.

## Not in test MVP

- GitHub webhook admission service.
- GitHub App.
- Image build/push or ACR.
- Package mirrors and seven-day dependency policy.
- Image signing.
- Egress proxy.
- Ticket/action broker.
- Stuck-job service.
- Custom UI.
- Untrusted-code tier.
