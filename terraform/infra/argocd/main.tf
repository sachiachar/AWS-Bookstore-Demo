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
  server = local.stack_out.host
  ca_cert = local.stack_out.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = local.server
    cluster_ca_certificate = local.ca_cert
  }
}

resource "helm_release" "argocd" {
    name = "argocd"

    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"

    namespace = "argocd"

    create_namespace = true
    version = "5.36.1"

    values = [file("argocd.yaml")]
}
