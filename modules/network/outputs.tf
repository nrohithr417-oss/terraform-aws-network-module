output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"

  value = [
    for nat in aws_nat_gateway.this : nat.id
  ]
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"

  value = [
    for key, subnet in aws_subnet.this :
    subnet.id
    if startswith(key, "public-")
  ]
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"

  value = [
    for key, subnet in aws_subnet.this :
    subnet.id
    if startswith(key, "private-")
  ]
}

output "public_route_table_id" {
  description = "Public Route Table ID"

  value = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private Route Table IDs"

  value = [
    for rt in aws_route_table.private : rt.id
  ]
}

output "availability_zones" {
  description = "Availability Zones"

  value = var.availability_zones
}

output "public_security_group_id" {
  description = "Public Security Group ID"

  value = aws_security_group.public.id
}

output "private_security_group_id" {
  description = "Private Security Group ID"

  value = aws_security_group.private.id
}