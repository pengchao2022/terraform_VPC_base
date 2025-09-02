variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

# 堡垒机配置变量
variable "bastion_config" {
  description = "Configuration for bastion host"
  type = object({
    instance_type        = string
    ubuntu_ami_name      = string
    ubuntu_ami_owner     = string
    key_name             = string
    allowed_cidr_blocks  = list(string)
    enable_ssh           = bool
    volume_size          = number
    volume_type          = string
  })
  default = {
    instance_type      = "t3.micro"
    ubuntu_ami_name    = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ubuntu_ami_owner   = "099720109477" # Canonical的官方账户ID
    key_name           = "my-ubuntu-key"
    allowed_cidr_blocks = ["0.0.0.0/0"] # 生产环境应该限制为特定IP
    enable_ssh         = true
    volume_size        = 20
    volume_type        = "gp3"
  }
}

variable "create_bastion" {
  description = "Whether to create bastion host"
  type        = bool
  default     = true
}

variable "bastion_hostname" {
  description = "Bastion host hostname"
  type        = string
  default     = "bastion"
}