locals {
    root_dir = "${dirname(abspath(path.root))}"
    k8s_config_dir = "${local.root_dir}/.kube/"
    k8s_config_file = "${local.root_dir}/.kube/kubeconfig.yaml"
}

output "k8s_config_file" {
  value = local.k8s_config_file
}