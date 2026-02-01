resource "aws_vpc" "this" {
  count             = var.create_vpc ? 1 : 0
  cidr_block        = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

# Create public subnets
resource "aws_subnet" "this_public" {
  count                   = var.create_vpc ? length(var.public_subnets) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name        = "${var.vpc_name}-public-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}

# Create private subnets
resource "aws_subnet" "this_private" {
  count                   = var.create_vpc ? length(var.private_subnets) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    {
      Name        = "${var.vpc_name}-private-${count.index + 1}"
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge({ Name = "${var.vpc_name}-igw" }, var.tags)
}

# Elastic IP for NAT Gateway
resource "aws_eip" "this" {
  count  = var.create_vpc ? 1 : 0
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  count         = var.create_vpc ? 1 : 0
  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.this_public[0].id
  depends_on    = [aws_internet_gateway.this]
  tags          = merge({ Name = "${var.vpc_name}-natgw" }, var.tags)
}

# Route table for public subnets
resource "aws_route_table" "this_public" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }
  tags = merge({ Name = "${var.vpc_name}-public-rt" }, var.tags)
}

resource "aws_route_table_association" "this_public" {
  count          = var.create_vpc ? length(aws_subnet.this_public) : 0
  subnet_id      = aws_subnet.this_public[count.index].id
  route_table_id = aws_route_table.this_public[0].id
}

# Route table for private subnets
resource "aws_route_table" "this_private" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[0].id
  }
  tags = merge({ Name = "${var.vpc_name}-private-rt" }, var.tags)
}

resource "aws_route_table_association" "this_private" {
  count          = var.create_vpc ? length(aws_subnet.this_private) : 0
  subnet_id      = aws_subnet.this_private[count.index].id
  route_table_id = aws_route_table.this_private[0].id
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0
  name  = "${var.cluster_name}-${var.environment}"

  tags = merge(
    {
      Name        = "${var.cluster_name}-${var.environment}"
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_cluster ? 1 : 0
  name              = "/ecs/${var.cluster_name}-${var.environment}"
  retention_in_days = 30

  tags = merge(
    {
      Name        = "${var.cluster_name}-logs"
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}

# Output the vpc id, either created or from input
locals {
  vpc_id      = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cluster_arn = var.create_cluster ? aws_ecs_cluster.this[0].arn : var.cluster_arn
}
