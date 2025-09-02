# 子网输出
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnet_availability_zones" {
  description = "List of availability zones for public subnets"
  value       = aws_subnet.public[*].availability_zone
}

output "private_subnet_availability_zones" {
  description = "List of availability zones for private subnets"
  value       = aws_subnet.private[*].availability_zone
}

# NAT Gateway 输出
output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = aws_nat_gateway.nat[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IP addresses of NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "nat_gateway_private_ips" {
  description = "List of private IP addresses of NAT Gateways"
  value       = aws_nat_gateway.nat[*].private_ip
}

# Internet Gateway 输出
output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

# 路由表输出
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

# 路由表关联输出
output "public_route_table_association_ids" {
  description = "List of IDs of public route table associations"
  value       = aws_route_table_association.public[*].id
}

output "private_route_table_association_ids" {
  description = "List of IDs of private route table associations"
  value       = aws_route_table_association.private[*].id
}

# Elastic IP 输出
output "eip_ids" {
  description = "List of IDs of Elastic IPs for NAT Gateways"
  value       = aws_eip.nat[*].id
}

output "eip_public_ips" {
  description = "List of public IPs of Elastic IPs for NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# 可用区信息
output "availability_zones" {
  description = "List of availability zones used for subnets"
  value       = var.azs
}

# 模块输入参数（用于调试和验证）
output "vpc_id" {
  description = "The VPC ID passed to the module"
  value       = var.vpc_id
}

output "vpc_cidr_block" {
  description = "The VPC CIDR block passed to the module"
  value       = var.vpc_cidr_block
}

output "vpc_name" {
  description = "The VPC name passed to the module"
  value       = var.vpc_name
}