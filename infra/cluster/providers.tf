provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.reo.kube_config[0].host
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.reo.kube_config[0].cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

provider "helm" {
  kubernetes = {
    host                   = data.azurerm_kubernetes_cluster.reo.kube_config[0].host
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.reo.kube_config[0].cluster_ca_certificate)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    }
  }
}
