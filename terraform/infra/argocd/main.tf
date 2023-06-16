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
    host = local.kubeconf.clusters.0.cluster.server
    client_certificate = local.kubeconf.users.0.user.client-certificate-data
    client_key = local.kubeconf.users.0.user.client-key-data
    cluster_ca_certificate = local.kubeconf.clusters.0.cluster.certificate-authority-data
  }
}

provider "kubernetes" {
  kubernetes {
    host = local.kubeconf.clusters.0.cluster.server
    client_certificate = local.kubeconf.users.0.user.client-certificate-data
    client_key = local.kubeconf.users.0.user.client-key-data
    cluster_ca_certificate = local.kubeconf.clusters.0.cluster.certificate-authority-data
  }
}

provider "kubectl" {
  kubernetes {
    host = local.kubeconf.clusters.0.cluster.server
    client_certificate = local.kubeconf.users.0.user.client-certificate-data
    client_key = local.kubeconf.users.0.user.client-key-data
    cluster_ca_certificate = local.kubeconf.clusters.0.cluster.certificate-authority-data
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
