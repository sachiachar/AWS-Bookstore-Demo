
# Setting the variables for ArgoCD installation
variable "argo_namespace" {
    type = string
    default       = "argocd"
}

variable "argo_install_script" {
    type = string
    #default       = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml"
    default       = "services/install.yaml"
}