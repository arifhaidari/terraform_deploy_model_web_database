terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# the aws region where we want to deploy our various resources
provider "aws" {
  region = "eu-west-3"
  access_key = "my-access-key" # the access key created for the user who will be used by terraform
  secret_key = "my-secret-key" # the secret key created for the user who will be used by terraform
}