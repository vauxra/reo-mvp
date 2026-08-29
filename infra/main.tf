data "azurerm_resource_group" "reo" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

resource "azuread_group" "aks_admins" {
  display_name     = "${var.name_prefix}-aks-admins"
  security_enabled = true
}

resource "azuread_group_member" "current_operator" {
  group_object_id  = azuread_group.aks_admins.object_id
  member_object_id = data.azuread_client_config.current.object_id
}

resource "azurerm_log_analytics_workspace" "reo" {
  name                = "${var.name_prefix}-logs-eus2"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.reo.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = var.log_analytics_daily_quota_gb
}

resource "azurerm_virtual_network" "reo" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.reo.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = data.azurerm_resource_group.reo.name
  virtual_network_name = azurerm_virtual_network.reo.name
  address_prefixes     = [var.aks_subnet_cidr]
}

resource "azurerm_kubernetes_cluster" "reo" {
  name                = "${var.name_prefix}-aks"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.reo.name
  dns_prefix          = "${var.name_prefix}-aks"

  default_node_pool {
    name                 = "system"
    vm_size              = var.aks_node_size
    node_count           = var.aks_node_count
    auto_scaling_enabled = false
    vnet_subnet_id       = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  local_account_disabled = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = false
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = [azuread_group.aks_admins.object_id]
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.reo.id
  }
}

resource "azurerm_user_assigned_identity" "github_actions" {
  name                = "${var.name_prefix}-github-actions"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.reo.name
}

resource "azurerm_federated_identity_credential" "github_actions" {
  name                      = "github-actions-main"
  user_assigned_identity_id = azurerm_user_assigned_identity.github_actions.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "github_actions_cluster_user" {
  scope                = azurerm_kubernetes_cluster.reo.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}
