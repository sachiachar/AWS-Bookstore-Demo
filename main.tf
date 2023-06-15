terraform {
  required_version = ">= 0.15"
  required_providers {
    linode = {
      source  = "linode/linode"
      # version = "..."
    }
  }
  backend "s3" {}
}

provider "linode" {
  token = var.linode_api_token
}
