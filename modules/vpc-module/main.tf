# 创建 Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# 创建弹性 IP 用于 NAT Gateway
resource "aws_eip" "nat" {
  # 移除了 count，只创建一个 EIP
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-eip-single"
  }
}


# 创建公有子网
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index) # 例如：10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true # 公有子网中自动分配公网 IP

  tags = {
    Name = "${var.vpc_name}-public-subnet-${var.azs[count.index]}"
  }
}

# 创建私有子网
resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 10) # 例如：10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet-${var.azs[count.index]}"
  }
}

# 创建 NAT Gateway (每个可用区一个，放在公有子网)
resource "aws_nat_gateway" "nat" {
  # 移除了 count，只创建一个 NAT Gateway
  allocation_id = aws_eip.nat.id # 引用上面创建的单个EIP，不需要索引了
  subnet_id     = aws_subnet.public[0].id # 指定创建在第一个公有子网中。您可以选择任意一个公有子网，例如 aws_subnet.public[1].id
  tags = {
    Name = "${var.vpc_name}-nat-gw-single"
  }
  depends_on = [aws_internet_gateway.igw]
}

# 创建公有路由表
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# 公有子网关联公有路由表
resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 为每个私有子网创建单独的路由表
# 私有路由表（单个）
resource "aws_route_table" "private" {
  # 移除了 count，只创建一个路由表
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    # 正确：指向单个的NAT Gateway对象（不需要索引）
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.vpc_name}-private-rt-shared"
  }
}

# 路由表关联（所有私有子网都关联到这一个路由表）
resource "aws_route_table_association" "private" {
  # count 循环所有私有子网
  count          = length(aws_subnet.private[*].id)
  subnet_id      = aws_subnet.private[count.index].id
  # 所有子网都使用同一个路由表ID
  route_table_id = aws_route_table.private.id
}