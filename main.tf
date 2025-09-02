
# 定义可用区
data "aws_availability_zones" "available" {
  state = "available"
}

# 创建生产环境 VPC
resource "aws_vpc" "production" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "production-vpc"
    Env  = "Production"
  }
}

# 创建开发环境 VPC
resource "aws_vpc" "development" {
  cidr_block           = "172.16.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "development-vpc"
    Env  = "Development"
  }
}

# 获取前3个可用区
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

# 为生产环境 VPC 创建资源
module "production_vpc_resources" {
  source = "./modules/vpc-module"

  vpc_id          = aws_vpc.production.id
  vpc_cidr_block  = "10.0.0.0/16"
  vpc_name        = "production"
  azs             = local.azs
}

# 为开发环境 VPC 创建资源
module "development_vpc_resources" {
  source = "./modules/vpc-module"

  vpc_id          = aws_vpc.development.id
  vpc_cidr_block  = "172.16.0.0/16"
  vpc_name        = "development"
  azs             = local.azs
}