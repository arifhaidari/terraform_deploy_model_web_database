terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 1.6.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # kubernetes configuration file path
}

