#!/bin/bash
# Enable strict error handling: 
# -e : Exit immediately if a command exits with a non-zero status
# -u : Treat unset variables as an error and exit immediately
# -o pipefail : Return the exit status of the last command in the pipeline that failed
set -euo pipefail

# Change directory to the example Terraform configuration for the hello_world_app
cd ../../hello_world_app

# Initialize the Terraform configuration directory
# This sets up the backend for storing state and downloads necessary plugins.
terraform init

# Apply the Terraform configuration to create resources
# The -auto-approve flag skips interactive approval for automation purposes.
terraform apply -auto-approve

# Wait for 60 seconds to allow the instance sufficient time to boot up
# This could alternatively be handled in Terraform using a provisioner.
sleep 60 

# Extract the instance IP address from Terraform output in JSON format
# Use `jq` to parse the JSON and retrieve the IP address from 'instance_ip_addr'
# Pass the IP to `curl` to make an HTTP request on port 8080 with a timeout of 10 seconds.
terraform output -json | \
jq -r '.instance_ip_addr.value' | \
xargs -I {} curl http://{}:8080 -m 10

# If the HTTP request succeeds, destroy the Terraform-managed resources
# The -auto-approve flag skips the prompt to confirm the destruction.
terraform destroy -auto-approve

# Usage:
# To run this test script:
# 1. Ensure you are in the same directory as the script
# 2. Execute the script with: ./hello_world_test.sh
# 
# After obtaining the IP, you can manually verify the server's availability by using:
# terraform output -json | jq -r '.instance_ip_addr.value' | xargs -I {} curl http://{}:8080 -m 10
# 
# This script includes a 60-second delay, as the server may need additional time to initialize.
# For additional manual monitoring, you can use the command:
# watch "curl ip_address:8080"
# to send repeated requests to the server at the specified IP address.
