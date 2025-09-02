variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "Bastion instance type"
  type        = string
  default     = "t3.micro"
}

variable "ubuntu_ami_name" {
  description = "Ubuntu AMI name pattern"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ubuntu_ami_owner" {
  description = "Ubuntu AMI owner ID"
  type        = string
  default     = "099720109477" # Canonical
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "hostname" {
  description = "Bastion host hostname"
  type        = string
  default     = "bastion"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null  # 可选：设置为可选参数
}
