# 获取最新的Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ubuntu_ami_owner]

  filter {
    name   = "name"
    values = [var.ubuntu_ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 创建堡垒机安全组
resource "aws_security_group" "bastion" {
  name        = "${var.vpc_name}-bastion-sg"
  description = "Security group for Ubuntu bastion host"
  vpc_id      = var.vpc_id
  

  # 入站规则 - SSH 允许 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 生产环境应限制为特定IP
  }

  # 入站规则 - ICMP 允许
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  # 出站规则 - 允许所有出站流量
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.vpc_name}-bastion-sg"
    Environment = var.environment
    OS          = "Ubuntu"
  }
}

# 创建堡垒机实例
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0] # 使用第一个公有子网
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name

  # 根卷配置
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    encrypted             = true
    delete_on_termination = true
    
    tags = {
      Name        = "${var.vpc_name}-bastion-root-volume"
      Environment = var.environment
    }
  }

  # 启用详细监控
  monitoring = true

  # 标签
  tags = {
    Name        = "${var.vpc_name}-bastion-host"
    Environment = var.environment
    Role        = "bastion"
    OS          = "Ubuntu"
    OS-Version  = "22.04"
  }

  # 确保实例有公有IP
  associate_public_ip_address = true

  # 用户数据 - Ubuntu 系统初始化脚本
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    hostname    = "${var.hostname}-${var.vpc_name}"
    region      = var.region
    environment = var.environment
  }))

  # 生命周期配置，防止意外删除
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami]
  }
}

# 创建弹性IP并关联到堡垒机
resource "aws_eip" "bastion" {
  domain = "vpc"
  instance = aws_instance.bastion.id

  tags = {
    Name        = "${var.vpc_name}-bastion-eip"
    Environment = var.environment
    OS          = "Ubuntu"
  }
}
