########################################
# Project Configuration
########################################

variable "project_name" {
  description = "Project name."
  type        = string

  validation {
    condition     = length(var.project_name) >= 3
    error_message = "Project name must be at least 3 characters."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition = contains(
      ["dev", "qa", "stage", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, qa, stage, or prod."
  }
}

variable "aws_region" {
  description = "AWS region where network resources will be created."
  type        = string
  default     = "ap-south-1"
}

########################################
# Network Configuration
########################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the three public subnets."
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) == 3 &&
      alltrue([
        for cidr in var.public_subnet_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "Exactly 3 valid public subnet CIDR blocks are required."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the three private subnets."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_cidrs) == 3 &&
      alltrue([
        for cidr in var.private_subnet_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "Exactly 3 valid private subnet CIDR blocks are required."
  }
}

variable "availability_zones" {
  description = "Availability Zones used for the public and private subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 Availability Zones are required."
  }
}

########################################
# NAT Gateway Configuration
########################################

variable "single_nat_gateway" {
  description = "Deploy a single NAT Gateway instead of one NAT Gateway per Availability Zone."
  type        = bool
  default     = true
}

########################################
# IPv6 Configuration
########################################

variable "enable_ipv6" {
  description = "Enable IPv6 support for the VPC."
  type        = bool
  default     = false
}

########################################
# VPC Flow Logs
########################################

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs."
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention period for VPC Flow Logs."
  type        = number
  default     = 30

  validation {
    condition = contains(
      [
        1,
        3,
        5,
        7,
        14,
        30,
        60,
        90,
        120,
        150,
        180,
        365,
        400,
        545,
        731,
        1096,
        1827,
        2192,
        2557,
        2922,
        3288,
        3653
      ],
      var.flow_logs_retention_days
    )

    error_message = "Flow Logs retention days must be a valid CloudWatch Logs retention value."
  }
}

########################################
# VPC Endpoints
########################################

variable "enable_endpoints" {
  description = "Enable supported VPC endpoints."
  type        = bool
  default     = false
}

########################################
# Common Tags
########################################

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}