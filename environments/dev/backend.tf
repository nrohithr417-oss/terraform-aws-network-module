terraform {
  backend "s3" {

    bucket = "terraform-network-state-rohith-2026"

    key = "dev/terraform.tfstate"

    region = "ap-south-1"

    encrypt = true

    dynamodb_table = "terraform-network-lock"
  }
}