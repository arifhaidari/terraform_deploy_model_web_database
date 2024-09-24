terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 1.6.1"
    }
     helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
  }
}

# Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config" # kubernetes configuration file path
}

# Helm provider to manage Helm charts in Kubernetes
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Path to the Kubernetes config used by Helm
  }
}

