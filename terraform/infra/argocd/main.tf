terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
  }
  backend "remote" {
    organization = "bookstore"
    workspaces  {
      name = "Linode-Bookstore-Demo-ArgoCD"
    }
  }
}

data "terraform_remote_state" "k8s_config" {

    backend = "remote"

    config = {
        organization = "bookstore"
        workspaces = {
            name = "Linode-Bookstore-Demo-K8S-Ops"
        }
    }
}

locals {
  stack_out = data.terraform_remote_state.k8s_config.outputs
  kubeconf = local.stack_out.kubeconf
}

provider "helm" {
  kubernetes {
    host = local.kubeconf.host
    cluster_ca_certificate = local.kubeconf.cluster_ca_certificate
  }
}

provider "kubernetes" {
  kubernetes {
    host = local.kubeconf.host
    cluster_ca_certificate = local.kubeconf.cluster_ca_certificate
  }
}

provider "kubectl" {
  kubernetes {
    host = local.kubeconf.host
    cluster_ca_certificate = local.kubeconf.cluster_ca_certificate
    load_config_file = false
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
