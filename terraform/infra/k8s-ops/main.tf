terraform {
  required_version = ">= 0.15"
  required_providers {
    linode = {
      source  = "linode/linode"
      # version = "..."
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
  }
   backend "remote" {
     organization = "bookstore"

     workspaces {
       name = "Linode-Bookstore-Demo-K8S-Ops"
     }
   }
}

provider "linode" {
  token = var.linode_api_token
}

provider "helm" {
  kubernetes {

    
    #config_path = yamldecode(linode_lke_cluster.bookstore-operations.kubeconfig).filename
    host = "${yamldecode(linode_lke_cluster.bookstore-operations.kubeconfig).clusters.0.cluster.server}"
    cluster_ca_certificate = "${base64decode(yamldecode(linode_lke_cluster.bookstore-operations.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
    config_path = local.k8s_config_file
  }
}

# resource "helm_release" "argocd" {
  
#     name = "argocd"
#     repository = "https://argoproj.github.io/argo-helm"
#     chart = "argo-cd"
#     namespace = "argocd"
#     create_namespace = true
#     version = "3.35.4"

#     values = [file("argocd.yaml")]
# }

resource "helm_release" "argocd" {
  namespace        = var.namespace
  create_namespace = true
  name             = var.release_name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version

  # Helm chart deployment can sometimes take longer than the default 5 minutes
  timeout = var.timeout_seconds

  # If values file specified by the var.values_file input variable exists then apply the values from this file
  # else apply the default values from the chart
  values = [fileexists("${path.root}/${var.values_file}") == true ? file("${path.root}/${var.values_file}") : ""]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.admin_password == "" ? "" : bcrypt(var.admin_password)
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = var.insecure == false ? false : true
  }

  set {
    name  = "dex.enabled"
    value = var.enable_dex == true ? true : false
  }
}

