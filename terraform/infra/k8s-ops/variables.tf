variable "linode_api_token" {
    sensitive = true
}

variable "k8s_label" {
  default       = "bookstore-operations"
}

variable "k8s_version" {
  default       = "1.25"
}

variable "k8s_region" {
  default       = "ap-south"
}

variable "k8s_tags" {
  type = list(string)
  default       = ["bookstore-ops-k8s"]
}

variable "k8s_node_count" {
  type = number
  default = 1
}

variable "k8s_node_type" {
  default       = "g6-standard-1"
}

variable "release_name" {
  type        = string
  description = "Helm release name"
  default     = "argocd"
}
variable "namespace" {
  description = "Namespace to install ArgoCD chart into"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of ArgoCD chart to install"
  type        = string
  default     = "5.36.2" # See https://artifacthub.io/packages/helm/argo/argo-cd for latest version(s)
}

# Helm chart deployment can sometimes take longer than the default 5 minutes
variable "timeout_seconds" {
  type        = number
  description = "Helm chart deployment can sometimes take longer than the default 5 minutes. Set a custom timeout here."
  default     = 800 # 10 minutes
}

variable "admin_password" {
  description = "Default Admin Password"
  type        = string
  default     = ""
}

variable "values_file" {
  description = "The name of the ArgoCD helm chart values file to use"
  type        = string
  default     = "argocd.yaml"
}

variable "enable_dex" {
  type        = bool
  description = "Enabled the dex server?"
  default     = true
}

variable "insecure" {
  type        = bool
  description = "Disable TLS on the ArogCD API Server?"
  default     = false
}

