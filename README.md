# Terraform (Under Development)

Infrastructure as Code:

Deployed websites and databases

I did deploy using kubernetes provider.

I will now use Terraform's helm provider to deploy the same WordPress application on the Kubernetes cluster, but this time using Helm charts.

in another part of this repo I will experiment different aspects of terraform

AWS instance configuration

deploying using workflow - CI/CD pipelines - Github Actions

     ├── README.md
     ├── aws-data2
     │ ├── ebs.tf
     │ ├── instances.tf
     │ ├── output.tf
     │ ├── provider.tf
     │ ├── security.tf
     │ ├── terraform.tfvars
     │ └── variables.tf
     ├── kubernetes
     │ ├── charts
     │ │ ├── mysql-chart
     │ │ │ ├── Chart.yaml
     │ │ │ ├── charts
     │ │ │ ├── templates
     │ │ │ │ ├── \_helpers.tpl
     │ │ │ │ ├── deployment.yaml
     │ │ │ │ ├── service.yaml
     │ │ │ │ └── tests
     │ │ │ │ └── test-connection.yaml
     │ │ │ └── values.yaml
     │ │ └── wordpress-chart
     │ │ ├── Chart.yaml
     │ │ ├── charts
     │ │ ├── templates
     │ │ │ ├── \_helpers.tpl
     │ │ │ ├── deployment.yaml
     │ │ │ ├── service.yaml
     │ │ │ └── tests
     │ │ │ └── test-connection.yaml
     │ │ └── values.yaml
     │ ├── get_helm.sh
     │ ├── main.tf
     │ ├── provider.tf
     │ ├── terraform.tfstate
     │ └── terraform.tfstate.backup
     ├── n1_start
     │ ├── main.tf
     │ ├── terraform.tfstate
     │ └── terraform.tfstate.backup
     ├── n2_route_rds
     │ ├── aws_backend
     │ │ ├── main.tf
     │ │ └── terraform.tfstate
     │ ├── info.txt
     │ └── web_app
     │ ├── main.tf
     │ └── project_architecture.png
     ├── notes.txt
     ├── reports
     │ ├── commands.txt
     │ └── reports.odt
     ├── requirements.txt
     ├── terraform.tfstate
     └── terraform.tfstate.backup
