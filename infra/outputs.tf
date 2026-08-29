output "aks_name" {
  value = azurerm_kubernetes_cluster.reo.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.reo.workspace_id
}

output "github_actions_client_id" {
  value = azurerm_user_assigned_identity.github_actions.client_id
}

output "github_actions_principal_id" {
  value = azurerm_user_assigned_identity.github_actions.principal_id
}

output "reo_workbook_id" {
  value = azurerm_application_insights_workbook.reo_runs.id
}
