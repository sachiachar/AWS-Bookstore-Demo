
# Declare the variable for storing the Linode API token. This needs to be created on Terraform cloud.
variable "linode_api_token" {
  sensitive = true
}

# Declare the providers used
terraform {
  required_version = ">= 0.15"
  required_providers {
    linode = {
      source = "linode/linode"
      # version = "..."
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1" #Pinning the versions. This will need to be updated as new versions gets released.
    }
  }
  cloud {
    organization = "bookstore"

    workspaces {
      name = "Linode-k8s-clusters"
    }
  }
}

# Set the Linode API token from the Terraform cloud variable.
provider "linode" {
  token = var.linode_api_token
}

# Merge the kubeconfig files into a single kubeconfig for ease of use. Although this isn't mandatory.
resource "null_resource" "config" {

  # download kubectl
  provisioner "local-exec" {
    command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl"
  }

  provisioner "local-exec" {
    command = "./kubectl config view --flatten >> ${local.k8s_config_file_merged}"
    environment = {
      KUBECONFIG = "${local.k8s_config_file_ops}:${local.k8s_config_file_app}"
    }
  }

  # Explicitly set the dependency, as terraform cannot determine the dependencies.
  depends_on = [
    linode_lke_cluster.bookstore-operations,
    linode_lke_cluster.bookstore-applications
  ]
}

# Set the kubeconfig path to kubernetes cluster used for operations.
provider "kubernetes" {
  config_path = local.k8s_config_file_ops
}

# Output the path to merged kubeconfig manifest.
output "k8s_config_file_merged" {
  value = local.k8s_config_file_merged
}


