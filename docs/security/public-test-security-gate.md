# REO public test security gate

## No credential exposure found

Current repo files contain no Azure client secret, GitHub PAT, GitHub App key, webhook secret, or kubeconfig.

GitHub OIDC uses a short-lived Azure token. Trust is scoped to:

```text
repo:vauxra/reo-mvp:ref:refs/heads/main
```

The public values needed by the action are Azure IDs only. They are not credentials.

## Not safe to apply yet

A person who can change `main` can change the GitHub workflow or Argo manifests. They could submit arbitrary 60-second jobs, alter cron frequency, or use pod network egress. AKS will not autoscale, but this can still consume the fixed node, generate logs, and attack external services.

Current GitHub state:

```text
Repository: public
main branch: not created yet
main protection: not configured
Actions: enabled; all actions allowed; SHA pinning not required
Default workflow token: read-only
```

## MVP acceptance

For this short-lived test, the owner-only `main` trust boundary is accepted. Formal branch protection and GitHub Actions allow-list policy are deferred.

Keep three cheap controls before apply:

1. Disable AKS local accounts.
2. Add `ResourceQuota` and `LimitRange` in `reo-runs`.
3. Disable service-account token automount for job pods.

These controls are now in Terraform/manifests. Re-plan before apply to verify the final Azure scope.

## Residual test risk

After these controls, a trusted maintainer can still authorize code execution by merging it to `main`. That is the explicit trust boundary for this test MVP.
