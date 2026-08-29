variable "subscription_id" { type = string }
variable "resource_group_name" { type = string }
variable "aks_name" { type = string }
variable "github_actions_principal_id" { type = string }
variable "argo_server_enabled" {
  type    = bool
  default = false
}
