terraform {
  # the backend is alreay 
  backend "s3" {
    bucket         = "mlops-directive-tf-state"
    key            = "n4_third_pary_tools/consul/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# in the following source read more instructions, how to deploy in production 
module "consul" {
  source = "git@github.com:hashicorp/terraform-aws-consul.git"
}