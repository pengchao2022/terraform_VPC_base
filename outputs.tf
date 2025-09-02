# VPC 信息输出
output "vpc_ids" {
  description = "The IDs of the created VPCs"
  value = {
    production  = aws_vpc.production.id
    development = aws_vpc.development.id
  }
}

output "vpc_cidr_blocks" {
  description = "The CIDR blocks of the created VPCs"
  value = {
    production  = aws_vpc.production.cidr_block
    development = aws_vpc.development.cidr_block
  }
}

# 生产环境输出
output "production_public_subnets" {
  description = "IDs and details of production public subnets"
  value       = module.production_vpc_resources.public_subnet_ids
}

output "production_private_subnets" {
  description = "IDs and details of production private subnets"
  value       = module.production_vpc_resources.private_subnet_ids
}

output "production_nat_gateways" {
  description = "IDs of production NAT Gateways"
  value       = module.production_vpc_resources.nat_gateway_ids
}

output "production_igw" {
  description = "ID of production Internet Gateway"
  value       = module.production_vpc_resources.igw_id
}

# 开发环境输出
output "development_public_subnets" {
  description = "IDs and details of development public subnets"
  value       = module.development_vpc_resources.public_subnet_ids
}

output "development_private_subnets" {
  description = "IDs and details of development private subnets"
  value       = module.development_vpc_resources.private_subnet_ids
}

output "development_nat_gateways" {
  description = "IDs of development NAT Gateways"
  value       = module.development_vpc_resources.nat_gateway_ids
}

output "development_igw" {
  description = "ID of development Internet Gateway"
  value       = module.development_vpc_resources.igw_id
}

# 详细子网信息（可选）
output "production_public_subnets_details" {
  description = "Detailed information about production public subnets"
  value = {
    ids           = module.production_vpc_resources.public_subnet_ids
    cidr_blocks   = module.production_vpc_resources.public_subnet_cidr_blocks
    availability_zones = module.production_vpc_resources.public_subnet_availability_zones
  }
}

output "production_private_subnets_details" {
  description = "Detailed information about production private subnets"
  value = {
    ids           = module.production_vpc_resources.private_subnet_ids
    cidr_blocks   = module.production_vpc_resources.private_subnet_cidr_blocks
    availability_zones = module.production_vpc_resources.private_subnet_availability_zones
  }
}

output "development_public_subnets_details" {
  description = "Detailed information about development public subnets"
  value = {
    ids           = module.development_vpc_resources.public_subnet_ids
    cidr_blocks   = module.development_vpc_resources.public_subnet_cidr_blocks
    availability_zones = module.development_vpc_resources.public_subnet_availability_zones
  }
}

output "development_private_subnets_details" {
  description = "Detailed information about development private subnets"
  value = {
    ids           = module.development_vpc_resources.private_subnet_ids
    cidr_blocks   = module.development_vpc_resources.private_subnet_cidr_blocks
    availability_zones = module.development_vpc_resources.private_subnet_availability_zones
  }
}

# 可用区信息
output "availability_zones_used" {
  description = "List of availability zones used in the deployment"
  value       = local.azs
}