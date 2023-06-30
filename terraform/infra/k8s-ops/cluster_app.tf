# Cluster definition template. Use this template for adding any new clusters.

# Creating the variables required for setting up Application cluster
variable "k8s_label_app" {
  default = "bookstore-applications"
}

variable "k8s_version_app" {
  default = "1.26"
}

variable "k8s_region_app" {
  default = "ap-south"
}

variable "k8s_tags_app" {
  type    = list(string)
  default = ["bookstore-apps-k8s"]
}

variable "k8s_node_count_app" {
  type    = number
  default = 1
}

variable "k8s_node_type_app" {
  default = "g6-standard-1"
}

# Cluster for setting up the apps/microservices. Initially a single node cluster is being setup.
resource "linode_lke_cluster" "bookstore-applications" {
  label       = var.k8s_label_app
  k8s_version = var.k8s_version_app
  region      = var.k8s_region_app
  tags        = var.k8s_tags_app

  pool {
    type  = var.k8s_node_type_app
    count = var.k8s_node_count_app
  }
}

# Create a kubeconfig file locally for applications
resource "local_file" "k8s_config_app" {
  content         = nonsensitive(base64decode(linode_lke_cluster.bookstore-applications.kubeconfig))
  filename        = local.k8s_config_file_app
  file_permission = "0600"
}

# Output the kubeconfig filename. This is required for using the file path in other workspaces.
output "k8s_config_file_app" {
  value = local.k8s_config_file_app
}

# Output the context information for the application cluster
output "k8s_config_context_app" {
  value = yamldecode(nonsensitive(base64decode(linode_lke_cluster.bookstore-applications.kubeconfig))).contexts[0].context
}

