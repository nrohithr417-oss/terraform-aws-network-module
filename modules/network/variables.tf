########################################
# Project Configuration
########################################

variable "project_name" {
  description = "Project name"

  type = string

  validation {
    condition     = length(var.project_name) > 2
    error_message = "Project name must be at least 3 characters."
  }
}

variable "environment" {
  description = "Environment"

  type = string

  validation {
    condition = contains(
      ["dev", "qa", "stage", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, qa, stage or prod."
  }
}

variable "aws_region" {
  description = "AWS Region"

  type    = string
  default = "ap-south-1"
}

########################################
# Network Configuration
########################################

variable "vpc_cidr" {
  description = "VPC CIDR"

  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"

  type = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "Exactly 3 public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"

  type = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "Exactly 3 private subnet CIDRs are required."
  }
}

variable "availability_zones" {
  description = "Availability Zones"

  type = list(string)

  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 Availability Zones are required."
  }
}

########################################
# Optional Features
########################################

variable "enable_ipv6" {
  description = "Enable IPv6 for the VPC"

  type    = bool
  default = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"

  type    = bool
  default = false
}

variable "flow_logs_retention_days" {
  description = "CloudWatch log retention"

  type    = number
  default = 30
}

variable "enable_endpoints" {
  description = "Enable VPC Endpoints"

  type    = bool
  default = false
}

variable "single_nat_gateway" {
  description = "Deploy Single NAT Gateway"

  type    = bool
  default = true
}

########################################
# Tags
########################################

variable "tags" {
  description = "Common Tags"

  type    = map(string)
  default = {}
}