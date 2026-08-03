module "network" {

  source = "../../modules/network"

  project_name = var.project_name

  environment = var.environment

  aws_region = var.aws_region

  vpc_cidr = var.vpc_cidr

  public_subnet_cidrs = var.public_subnet_cidrs

  private_subnet_cidrs = var.private_subnet_cidrs

  availability_zones = var.availability_zones

  tags = var.tags

  enable_flow_logs = var.enable_flow_logs

  enable_ipv6 = var.enable_ipv6

  enable_endpoints = var.enable_endpoints

  single_nat_gateway = var.single_nat_gateway
}