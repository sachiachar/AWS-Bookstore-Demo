terraform {
  required_version = ">= 0.15"
  required_providers {
    linode = {
      source  = "linode/linode"
      # version = "..."
    }
  }
   backend "remote" {
     organization = "bookstore"

     workspaces {
       name = "Linode-Bookstore-Demo-K8S-Ops"
     }
   }
}

provider "linode" {
  token = var.linode_api_token
}

