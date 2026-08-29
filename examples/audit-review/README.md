# REO audit review

Open the REO Log Analytics workspace.

Run:

```text
examples/audit-review/reo-audit.kql
```

Expected baseline evidence:

```text
REO Python one-off passed
REO Python cron passed
REO_AUDIT_MARKER=one-off
REO_AUDIT_MARKER=cron
```

The query is namespace-scoped to `reo-runs` and shows the latest 24 hours.
