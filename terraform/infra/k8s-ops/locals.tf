#Pin the paths used for storing the kubeconfig files. This needs to be updated whenever a new cluster is being added.

locals {
  root_dir               = dirname(abspath(path.root))
  k8s_config_dir         = "${local.root_dir}/.kube/"
  k8s_config_file_ops    = "${local.root_dir}/.kube/kubeconfig_ops.yaml"
  k8s_config_file_app    = "${local.root_dir}/.kube/kubeconfig_app.yaml"
  k8s_config_file_merged = "${local.root_dir}/.kube/kubeconfig.yaml"
}
