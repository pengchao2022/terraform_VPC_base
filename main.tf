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



# 创建SSH密钥对
resource "aws_key_pair" "bastion_server_key" {
  key_name   = "basion-server-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/h331ZWQQggV5Pp78eQ18Qi3lOytWJhuGacssp5gTCmuIzmMfIW+t0fhDjWq6uda1t7NeYTh0zu5+36vkiy5s3Gr1M764X3qGKeGFmC7qe1kyF7RtVoZ4adufBgoNxtWi9zGmSBVi3G98YLhq0Tuj0mV9FT9l1F3NBOd3YbtCSWJ3Lx3WH9hMJ7eGAsBek8hatCtlDIFMQeF/xW4WBufWYkghjJE0G/Z9q4bJewrERD4B7GlDe+GGN8wAvehKKASySWgeeIwu+w6LYR7yzi+hyCCL+jyiycJ113u0gMo/oavdlFlVUeoJhmjsL46sjpgKPr2Yb0GhEVBOCW/rBXPFq+24zx/uds1PK/HtVNanr5kQBpJ4yT57hKhKhuNXWhJwuwQpzEFkwt36RqNFC/7CpH0BiRaafHDggBSnzPsNEECHnPnfgvzfcKoxMNcbbgYwZxNFEBD2Bjd11T1iS0aIxlO7RA2IMGl0Ch03lE3ztbiafRVIw6pTy09ehi7e+NE= pengchaoma@Pengchaos-MacBook-Pro.local" # 替换为您的公钥内容
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
  
  key_name          = aws_key_pair.bastion_server_key.key_name  # 修正资源名称
  vpc_id           = aws_vpc.production.id  # 直接引用production VPC
  vpc_name         = "production"
  public_subnet_ids = module.production_vpc_resources.public_subnet_ids  # 修正模块引用
  environment      = "production"  # 明确指定环境
  instance_type    = var.bastion_config.instance_type
  ubuntu_ami_name  = var.bastion_config.ubuntu_ami_name
  ubuntu_ami_owner = var.bastion_config.ubuntu_ami_owner
  allowed_cidr_blocks = var.bastion_config.allowed_cidr_blocks
  volume_size      = var.bastion_config.volume_size
  volume_type      = var.bastion_config.volume_type
  hostname         = var.bastion_hostname
  region           = var.aws_region
}

# 为开发环境创建堡垒机
module "development_bastion" {
  count   = var.create_bastion ? 1 : 0
  source  = "./modules/bastion-module"
  
  key_name          = aws_key_pair.bastion_server_key.key_name  # 修正资源名称
  vpc_id           = aws_vpc.development.id  # 直接引用development VPC
  vpc_name         = "development"
  public_subnet_ids = module.development_vpc_resources.public_subnet_ids  # 修正模块引用
  environment      = "development"  # 明确指定环境
  instance_type    = var.bastion_config.instance_type
  ubuntu_ami_name  = var.bastion_config.ubuntu_ami_name
  ubuntu_ami_owner = var.bastion_config.ubuntu_ami_owner
  allowed_cidr_blocks = var.bastion_config.allowed_cidr_blocks
  volume_size      = var.bastion_config.volume_size
  volume_type      = var.bastion_config.volume_type
  hostname         = var.bastion_hostname
  region           = var.aws_region
}

# 调用安全组模块
module "prod_bastion_security_group" {
  source = "./modules/security-group"

  name_prefix            = "prod-bastion"
  vpc_id                 = aws_vpc.production.id
  allowed_ssh_cidr_blocks = ["192.168.1.0/24", "10.0.0.0/16"] # 限制为内部网络
  bastion_instance_ids   = aws_instance.bastion[*].id
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

module "dev_bastion_security_group" {
  source = "./modules/security-group"

  name_prefix            = "dev-bastion"
  vpc_id                 = aws_vpc.development.id
  allowed_ssh_cidr_blocks = ["192.168.1.0/24", "10.0.0.0/16"] # 限制为内部网络
  bastion_instance_ids   = aws_instance.bastion[*].id
  tags = {
    Environment = "development"
    ManagedBy   = "terraform"
  }
}

# 将安全组关联到实例（如果在实例创建时关联）
resource "aws_instance" "bastion" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  vpc_security_group_ids = [module.bastion_security_group.security_group_id] # 在这里关联安全组
  
  tags = {
    Name = "bastion-${count.index + 1}"
  }
}
