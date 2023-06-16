resource "linode_lke_cluster" "bookstore-operations" {
    label       = var.k8s_label
    k8s_version = var.k8s_version
    region      = var.k8s_region
    tags        = var.k8s_tags

    pool {
        type  = var.k8s_node_type
        count = var.k8s_node_count
    }
}

resource "local_file" "k8s_config" {
    content = "${nonsensitive(base64decode(linode_lke_cluster.bookstore-operations.kubeconfig))}"
    filename = "${local.k8s_config_file}"
    file_permission = "0600"
}

output "host" {
    value = "${nonsensitive(base64decode(linode_lke_cluster.bookstore-operations.kubeconfig).clusters.0.cluster.server)}"
}

output "client_certificate" {
    value = "${nonsensitive(base64decode(linode_lke_cluster.bookstore-operations.kubeconfig).users.0.user.client-certificate-data)}"
}

output "client_key" {
    value = "${nonsensitive(base64decode(linode_lke_cluster.bookstore-operations.kubeconfig).users.0.user.client-key-data)}"
}

output "cluster_ca_certificate" {
    value = "${nonsensitive(base64decode(linode_lke_cluster.bookstore-operations.kubeconfig).clusters.0.cluster.certificate-authority-data)}"
}

