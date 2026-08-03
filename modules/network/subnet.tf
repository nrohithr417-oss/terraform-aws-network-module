########################################
# Subnets
########################################

resource "aws_subnet" "this" {

  for_each = local.all_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.type == "public"

  ipv6_cidr_block = var.enable_ipv6 ? cidrsubnet(
    aws_vpc.this.ipv6_cidr_block,
    8,
    tonumber(split("-", each.key)[1])
  ) : null

  assign_ipv6_address_on_creation = var.enable_ipv6

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value.type}-${each.value.name}"
      Type = each.value.type
    }
  )
}