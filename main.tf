
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

# 为生产环境创建堡垒机
module "production_bastion" {
  count   = var.create_bastion ? 1 : 0
  source  = "./modules/bastion-module"

  vpc_id           = aws_vpc.main["production"].id
  vpc_name         = "production"
  public_subnet_ids = module.vpc_resources["production"].public_subnet_ids
  environment      = var.environment
  instance_type    = var.bastion_config.instance_type
  ubuntu_ami_name  = var.bastion_config.ubuntu_ami_name
  ubuntu_ami_owner = var.bastion_config.ubuntu_ami_owner
  key_name         = var.bastion_config.key_name
  allowed_cidr_blocks = var.bastion_config.allowed_cidr_blocks
  enable_ssh       = var.bastion_config.enable_ssh
  volume_size      = var.bastion_config.volume_size
  volume_type      = var.bastion_config.volume_type
  hostname         = var.bastion_hostname
  region           = var.aws_region
}

# 为开发环境创建堡垒机
module "development_bastion" {
  count   = var.create_bastion ? 1 : 0
  source  = "./modules/bastion-module"

  vpc_id           = aws_vpc.main["development"].id
  vpc_name         = "development"
  public_subnet_ids = module.vpc_resources["development"].public_subnet_ids
  environment      = var.environment
  instance_type    = var.bastion_config.instance_type
  ubuntu_ami_name  = var.bastion_config.ubuntu_ami_name
  ubuntu_ami_owner = var.bastion_config.ubuntu_ami_owner
  key_name         = var.bastion_config.key_name
  allowed_cidr_blocks = var.bastion_config.allowed_cidr_blocks
  enable_ssh       = var.bastion_config.enable_ssh
  volume_size      = var.bastion_config.volume_size
  volume_type      = var.bastion_config.volume_type
  hostname         = var.bastion_hostname
  region           = var.aws_region
}