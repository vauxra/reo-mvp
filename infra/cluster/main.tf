data "azurerm_kubernetes_cluster" "reo" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
}

resource "helm_release" "argo_workflows" {
  name             = "argo-workflows"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-workflows"
  namespace        = "argo"
  create_namespace = true

  set = [
    {
      name  = "server.enabled"
      value = tostring(var.argo_server_enabled)
    }
  ]
}

resource "kubernetes_namespace_v1" "reo_runs" {
  metadata {
    name = "reo-runs"
  }
}

resource "kubernetes_config_map_v1" "container_log_collection" {
  metadata {
    name      = "container-azm-ms-agentconfig"
    namespace = "kube-system"
  }

  data = {
    "schema-version"               = "v1"
    "config-version"               = "reo1"
    "log-data-collection-settings" = <<-EOT
      [log_collection_settings]
        [log_collection_settings.stdout]
          enabled = true
          exclude_namespaces = ["kube-system", "gatekeeper-system"]
        [log_collection_settings.stderr]
          enabled = true
          exclude_namespaces = ["kube-system", "gatekeeper-system"]
        [log_collection_settings.env_var]
          enabled = false
        [log_collection_settings.enrich_container_logs]
          enabled = true
        [log_collection_settings.schema]
          containerlog_schema_version = "v2"
    EOT
  }
}

resource "kubernetes_service_account_v1" "reo_workflow" {
  metadata {
    name      = "reo-workflow"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }

  automount_service_account_token = false
}

resource "kubernetes_service_account_v1" "reo_executor" {
  metadata {
    name      = "reo-executor"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }
}

resource "kubernetes_secret_v1" "reo_executor_token" {
  metadata {
    name      = "reo-executor.service-account-token"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.reo_executor.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_role_v1" "reo_executor" {
  metadata {
    name      = "reo-executor"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["workflowtaskresults"]
    verbs      = ["create", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "reo_executor" {
  metadata {
    name      = "reo-executor"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.reo_executor.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.reo_executor.metadata[0].name
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }
}

resource "kubernetes_resource_quota_v1" "reo_runs" {
  metadata {
    name      = "reo-runs-cap"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }

  spec {
    hard = {
      "pods"            = "3"
      "requests.cpu"    = "500m"
      "requests.memory" = "512Mi"
      "limits.cpu"      = "1"
      "limits.memory"   = "1Gi"
    }
  }
}

resource "kubernetes_limit_range_v1" "reo_runs" {
  metadata {
    name      = "reo-runs-defaults"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      min = {
        cpu    = "50m"
        memory = "64Mi"
      }
      max = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default = {
        cpu    = "250m"
        memory = "256Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}

resource "kubernetes_role_v1" "github_actions_submitter" {
  metadata {
    name      = "github-actions-submitter"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["workflows"]
    verbs      = ["create", "get", "list", "watch"]
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["cronworkflows"]
    verbs      = ["create", "get", "list", "watch", "patch", "update"]
  }
}

resource "kubernetes_role_binding_v1" "github_actions_submitter" {
  metadata {
    name      = "github-actions-submitter"
    namespace = kubernetes_namespace_v1.reo_runs.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.github_actions_submitter.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = var.github_actions_principal_id
    api_group = "rbac.authorization.k8s.io"
  }
}
