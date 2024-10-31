terraform {
  # the resources already handled in 
  # Specifies the backend configuration to store Terraform state files in S3.
  backend "s3" {
    bucket         = "mlops-directive-tf-state"           # S3 bucket name to store state files.
    key            = "n4_thrid_party_tools/web_app/terraform.tfstate" # Path to the state file within the bucket.
    region         = "us-east-1"                          # AWS region for the S3 bucket.
    dynamodb_table = "terraform-state-locking"            # DynamoDB table for state locking to prevent concurrent modifications.
    encrypt        = true                                 # Enables encryption for secure storage of state files.
  }

  # Specifies required providers with version constraints.
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # AWS provider from HashiCorp.
      version = "~> 3.0"          # Uses AWS provider version 3.x.
    }
  }
}

# Configures the AWS provider to use the specified region for resource creation.
provider "aws" {
  region = "us-east-1"  # Defines the default region for AWS operations.
}

# Sensitive variables for storing passwords for two different databases.
variable "db_pass_1" {
  description = "password for database #1"  # Description for database 1 password.
  type        = string                      # Defines the type as a string.
  sensitive   = true                        # Marks the variable as sensitive to hide its value in logs and outputs.
}

variable "db_pass_2" {
  description = "password for database #2"  # Description for database 2 password.
  type        = string                      # Defines the type as a string.
  sensitive   = true                        # Marks the variable as sensitive to hide its value in logs and outputs.
}

# Module configuration for the first version of the web application (web_app_1).
module "web_app_1" {
  source = "../web_app_module"            # Source path for the module.

  # Input Variables for configuring the module.
  bucket_prefix    = "web-app-1-data"     # Prefix for S3 bucket created for this web app's data.
  domain           = "mlopspractice.com"  # Domain name for web app 1.
  app_name         = "web-app-1"          # Name of the application, used in naming resources.
  environment_name = "production"         # Specifies the environment (production in this case).
  instance_type    = "t2.micro"           # AWS EC2 instance type for web app 1.
  create_dns_zone  = true                 # Indicates if a DNS zone should be created for the domain.
  db_name          = "webapp1db"          # Database name for web app 1.
  db_user          = "foo"                # Database username for web app 1.
  db_pass          = var.db_pass_1        # Password for database, passed as a sensitive variable.
}

# Module configuration for the second version of the web application (web_app_2).
module "web_app_2" {
  source = "../web_app_module"            # Source path for the module.

  # Input Variables for configuring the module.
  bucket_prefix    = "web-app-2-data"     # Prefix for S3 bucket created for this web app's data.
  domain           = "mlopstraining.com"  # Domain name for web app 2.
  app_name         = "web-app-2"          # Name of the application, used in naming resources.
  environment_name = "production"         # Specifies the environment (production in this case).
  instance_type    = "t2.micro"           # AWS EC2 instance type for web app 2.
  create_dns_zone  = true                 # Indicates if a DNS zone should be created for the domain.
  db_name          = "webapp2db"          # Database name for web app 2.
  db_user          = "bar"                # Database username for web app 2.
  db_pass          = var.db_pass_2        # Password for database, passed as a sensitive variable.
}


