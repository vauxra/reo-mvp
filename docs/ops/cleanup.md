# REO test cleanup

This MVP is intentionally disposable.

## Delete Azure resources

```bash
az group delete --name reo-mvp --yes --no-wait
```

This deletes the AKS cluster, node VM, VNet, Log Analytics workspace, **REO Run Operations workbook**, managed identity, and REO Entra role assignment. It does not delete the Microsoft Entra security group created for AKS admins.

## Delete the Entra test group

Get the group ID before deleting it:

```bash
terraform -chdir=infra state show azuread_group.aks_admins
```

Then delete that exact group through Terraform destroy or Microsoft Entra admin tooling.

## Remove local REO tools

See `docs/ops/tooling-state.md` for the exact user-local binary cleanup command.
