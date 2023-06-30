
# Declare the providers used
terraform {
  required_version = ">= 0.15"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
  cloud {
    organization = "bookstore"

    workspaces {
      name = "Linode-ArgoCD"
    }
  }
}

# Read the kubeconfig paths from the kuberbetes workspace. Make sure to use the same org & workspace names.
data "terraform_remote_state" "kubeconfig" {
  backend = "remote"

  config = {
    organization = "bookstore"

    workspaces = {
      name = "Linode-k8s-clusters"
    }
  }
}

# Set the kubeconfig path for the Operations cluster.
provider "kubernetes" {

  host = "${yamldecode(data.terraform_remote_state.kubeconfig.outputs.k8s_config_value_ops).clusters[0].cluster.server}"
  cluster_ca_certificate = "${base64decode(yamldecode(data.terraform_remote_state.kubeconfig.outputs.k8s_config_value_ops).clusters[0].cluster.certificate-authority-data)}"
  token = "${yamldecode(data.terraform_remote_state.kubeconfig.outputs.k8s_config_value_ops).users[0].user.token}"
}

# Create a new namespace for ArgoCD.
resource "kubernetes_namespace" "ArgoCD" {
  metadata {
    name = "argocd"
  }
}

# Template file is required for setting the trigger. This is to apply the new install scripts whenever there is change the install script.
# You can download the latest file from https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
data "template_file" "argocd_install" {
  template = "${file("${var.argo_install_script}")}"
}

# Install the ArgoCD install file.
resource "null_resource" "ArgoCD" {

  #Trigger when the yaml file changes
  triggers = {
    yaml_sha_install  = "${sha256(file("${var.argo_install_script}"))}"
  }

  # Install the ArgoCD YAML file.
  provisioner "local-exec" {
    command = "kubectl apply -n ${kubernetes_namespace.ArgoCD.metadata[0].name} -f ${var.argo_install_script}"

    environment = {
      KUBECONFIG = "${data.terraform_remote_state.kubeconfig.outputs.k8s_config_file_ops}"
    }
  }

  # Create a load balancer for external access
  provisioner "local-exec" {
    command = "kubectl patch svc argocd-server -n ${kubernetes_namespace.ArgoCD.metadata[0].name} -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"

    environment = {
      KUBECONFIG = "${data.terraform_remote_state.kubeconfig.outputs.k8s_config_file_ops}"
    }
  }
}

