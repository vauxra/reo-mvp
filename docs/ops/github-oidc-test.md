# REO GitHub OIDC test setup

## No secret required

GitHub Actions gets a short-lived Azure token through OIDC.

After `terraform apply`, set three normal GitHub Actions variables:

```bash
gh variable set AZURE_CLIENT_ID --repo vauxra/reo-mvp --body "$(terraform -chdir=infra output -raw github_actions_client_id)"
gh variable set AZURE_TENANT_ID --repo vauxra/reo-mvp --body "67dc4ae8-d764-438d-94b4-937c0f92a00b"
gh variable set AZURE_SUBSCRIPTION_ID --repo vauxra/reo-mvp --body "c6c9546a-a832-4543-9f6d-0e16d480936b"
```

These IDs are not secrets. Do not create GitHub repository secrets for this test.

## Trigger

Push a reviewed manifest change to `main`, or use **Actions → REO submit → Run workflow**.

The action can only create Argo `Workflow` and `CronWorkflow` resources in `reo-runs`.

## Cron test

The cron example is daily at 02:00 UTC so it cannot run away. For a live cron baseline, temporarily change it to every five minutes, observe one run in Log Analytics, then restore daily or delete the `CronWorkflow`.
