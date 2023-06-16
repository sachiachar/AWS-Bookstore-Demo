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
    host = "${yamldecode(linode_lke_cluster.bookstore-operations.kubeconfig).clusters.0.cluster.server}"
    cluster_ca_certificate = "${base64decode(yamldecode(linode_lke_cluster.bookstore-operations.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
  }
}

resource "helm_release" "argocd" {
  
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    namespace = "argocd"
    create_namespace = true
    version = "3.35.4"

    values = [file("argocd.yaml")]
}

