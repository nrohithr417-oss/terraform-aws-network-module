locals {

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  name_prefix = "${var.project_name}-${var.environment}"

  public_subnets = {
    for index, cidr in var.public_subnet_cidrs :
    "public-${index}" => {
      cidr = cidr
      az   = var.availability_zones[index]
      type = "public"
      name = index + 1
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs :
    "private-${index}" => {
      cidr = cidr
      az   = var.availability_zones[index]
      type = "private"
      name = index + 1
    }
  }

  all_subnets = merge(
    local.public_subnets,
    local.private_subnets
  )
}