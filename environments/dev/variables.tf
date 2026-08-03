variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "single_nat_gateway" {
  type = bool
}

variable "enable_flow_logs" {
  type = bool
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Log Group retention period in days"
  type        = number
}

variable "enable_endpoints" {
  type = bool
}

variable "enable_ipv6" {
  type = bool
}