# Terraform AWS Network Module

A production-ready Terraform module to provision an AWS VPC with public/private networking, security, and optional advanced features.

## Features

- VPC
- Internet Gateway
- Public & Private Subnets (3 AZs)
- NAT Gateway (Single or Multiple)
- Public & Private Route Tables
- Security Groups
- Network ACLs
- VPC Flow Logs
- VPC Endpoints (S3, DynamoDB, SSM)
- IPv6 Support
- Remote Backend (S3 + DynamoDB)
- GitHub Actions CI/CD
- TFLint
- tfsec

## Project Structure

```
terraform-aws-network-module/
├── backend/
├── environments/
│   └── dev/
├── modules/
│   └── network/
├── .github/
│   └── workflows/
├── .tflint.hcl
├── .gitignore
└── README.md
```

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  project_name          = "terraform-network"
  environment           = "dev"
  aws_region            = "ap-south-1"
  vpc_cidr              = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]
}
```

## Commands

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```

## CI/CD

GitHub Actions automatically runs:

- Terraform Format Check
- Terraform Validate
- TFLint
- tfsec
- Terraform Plan

## Author

Rohith Reddy