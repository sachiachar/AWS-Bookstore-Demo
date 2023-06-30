# Cluster definition template. Use this template for adding any new clusters.

# Creating the variables required for setting up Operations cluster
variable "k8s_label_ops" {
  default = "bookstore-operations"
}

variable "k8s_version_ops" {
  default = "1.26"
}

variable "k8s_region_ops" {
  default = "ap-south"
}

variable "k8s_tags_ops" {
  type    = list(string)
  default = ["bookstore-ops-k8s"]
}

variable "k8s_node_count_ops" {
  type    = number
  default = 1
}

variable "k8s_node_type_ops" {
  default = "g6-standard-1"
}

# Cluster for setting up the operational tools including CI/CD an Observability. Initially a single node cluster is being setup.

resource "linode_lke_cluster" "bookstore-operations" {
  label       = var.k8s_label_ops
  k8s_version = var.k8s_version_ops
  region      = var.k8s_region_ops
  tags        = var.k8s_tags_ops

  pool {
    type  = var.k8s_node_type_ops
    count = var.k8s_node_count_ops
  }
}

# Create a kubeconfig file locally for operations
resource "local_file" "k8s_config_ops" {
  content         = nonsensitive(base64decode(linode_lke_cluster.bookstore-operations.kubeconfig))
  filename        = local.k8s_config_file_ops
  file_permission = "0600"
}

# Output the kubeconfig value and remember to set it to sensitive
output "k8s_config_file_ops" {
  value = local.k8s_config_file_ops
}

# Output the context information for the operation cluster
output "k8s_config_value_ops" {
  value = base64decode(linode_lke_cluster.bookstore-operations.kubeconfig)
  sensitive = true
}

# Output the context information for the operation cluster
output "k8s_config_context_ops" {
  value = yamldecode(nonsensitive(base64decode(linode_lke_cluster.bookstore-operations.kubeconfig))).contexts[0].context
}


