variable "subscription_id" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }
variable "github_owner" { type = string }
variable "github_repository" { type = string }
variable "github_owner_id" { type = string }
variable "github_repository_id" { type = string }
variable "vnet_cidr" {
  type    = string
  default = "10.42.0.0/16"
}
variable "aks_subnet_cidr" {
  type    = string
  default = "10.42.0.0/22"
}
variable "aks_node_size" {
  type    = string
  default = "Standard_D2s_v5"
}
variable "aks_node_count" {
  type    = number
  default = 1
}
variable "log_analytics_daily_quota_gb" {
  type    = number
  default = 0.5
}
