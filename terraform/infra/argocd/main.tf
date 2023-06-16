terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
  }
  backend "remote" {
    organization = "bookstore"
    workspaces = {
      name = "Linode-Bookstore-Demo-ArgoCD"
    }
  }
}

data "terraform_remote_state" "Linode-Bookstore-Demo-K8S-Ops" {
    backend = "remote"

    config = {
        organization = "bookstore"
        workspaces = {
            name = "Linode-Bookstore-Demo-K8S-Ops"
        }
    }
}

provider "helm" {
  kubernetes {
    config_path = data.terraform_remote_state.k8s_config_file    
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