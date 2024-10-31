terraform {
  # Specifies the backend configuration for storing Terraform's state file in an S3 bucket.
  # The state file path includes a "workspaces" directory, allowing state separation by workspace.
  backend "s3" {
    bucket         = "mlops-directive-tf-state"                 # S3 bucket to store the state file
    key            = "n5_multiple_env/workspaces/terraform.tfstate" # Path to state file, shared across workspaces
    region         = "us-east-1"                                # AWS region for the S3 bucket
    dynamodb_table = "terraform-state-locking"                  # DynamoDB table for state locking to avoid conflicts
    encrypt        = true                                       # Enables server-side encryption for the state file
  }

  # Specifies required provider and version constraints
  required_providers {
    aws = {
      source  = "hashicorp/aws"                                 # AWS provider source
      version = "~> 3.0"                                        # AWS provider version, compatible with 3.x versions
    }
  }
}

# AWS provider configuration specifying the default region
provider "aws" {
  region = "us-east-1"                                          # Sets the AWS region for resource deployment
}

# Sensitive variable to store the database password securely
variable "db_pass" {
  description = "password for database"                         # Describes the purpose of the variable
  type        = string                                          # Sets the variable type as string
  sensitive   = true                                            # Marks variable as sensitive to mask in outputs
}

# Local variable to reference the current Terraform workspace (e.g., production, staging)
locals {
  environment_name = terraform.workspace                        # Dynamically sets the environment name from workspace
}

# Module to deploy the web application, using configurations adjusted by the workspace
module "web_app" {
  source = "../../n4_third_party_tools/web_app_module"          # Source path for the reusable web app module

  # Input Variables for the web app module
  bucket_prefix    = "web-app-data-${local.environment_name}"   # Prefix for S3 bucket, differentiated by environment
  domain           = "devopsdeployed.com"                       # Domain name for the app; likely managed by Route 53
  environment_name = local.environment_name                     # Passes the current environment to the module
  instance_type    = "t2.micro"                                 # Instance type for EC2 (chosen for cost-effectiveness)
  create_dns_zone  = terraform.workspace == "production" ? true : false # Only creates DNS zone in production
  db_name          = "${local.environment_name}mydb"            # DB name prefixed by environment for uniqueness
  db_user          = "foo"                                      # Static database username
  db_pass          = var.db_pass                                # Passes the secure DB password to the module
}
