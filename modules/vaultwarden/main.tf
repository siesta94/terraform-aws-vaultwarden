terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

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

# ------------------------------
# Application Load Balancer (ALB) with ACM
# ------------------------------

resource "aws_lb" "this" {
  name               = "${var.vpc_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.public_subnets

  enable_deletion_protection = false

  tags = merge(
    {
      Name        = "${var.vpc_name}-alb"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.vpc_name}-alb-sg"
  description = "Allow HTTP and HTTPS traffic to ALB"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${var.vpc_name}-alb-sg"
      Environment = var.environment
    },
    var.tags
  )
}

# ACM Certificate - import existing or request new
resource "aws_acm_certificate" "this" {
  count               = var.acm_certificate_arn == "" ? 1 : 0
  domain_name         = var.domain_name
  validation_method   = "DNS"

  tags = merge(
    {
      Name        = "${var.vpc_name}-acm"
      Environment = var.environment
    },
    var.tags
  )
}

# ------------------------------
# DNS Validation for ACM
# ------------------------------

# Route53 zone lookup for ACM validation (only used if domain_provider = "route53")
data "aws_route53_zone" "selected" {
  count = var.domain_provider == "route53" && var.acm_certificate_arn == "" ? 1 : 0
  name  = regex("(.*\\.)?([^\\.]+\\.[^\\.]+)$", var.domain_name)[0]
  private_zone = false
}

# Route53 Validation Record
resource "aws_route53_record" "acm_validation" {
  count   = var.domain_provider == "route53" && var.acm_certificate_arn == "" ? length(aws_acm_certificate.this[0].domain_validation_options) : 0
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = aws_acm_certificate.this[0].domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.this[0].domain_validation_options[count.index].resource_record_type
  records = [aws_acm_certificate.this[0].domain_validation_options[count.index].resource_record_value]
  ttl     = 60
}

# Cloudflare Validation Record
resource "cloudflare_record" "acm_validation" {
  for_each = var.domain_provider == "cloudflare" && var.acm_certificate_arn == "" ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.resource_record_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  } : {}

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = var.cloudflare_record_ttl
  proxied = false

  depends_on = [
    aws_acm_certificate.this
  ]
}

resource "aws_acm_certificate_validation" "this" {
  count                = var.acm_certificate_arn == "" ? 1 : 0
  certificate_arn      = aws_acm_certificate.this[0].arn
  validation_record_fqdns = (
    var.domain_provider == "route53" ?
    [for record in aws_route53_record.acm_validation : record.fqdn] :
    [for record in cloudflare_record.acm_validation : record.name]
  )
}

# ------------------------------
# Application main DNS record (ALB mapping)
# ------------------------------
resource "cloudflare_record" "app_domain" {
  count = var.domain_provider == "cloudflare" && var.acm_certificate_arn == "" ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = trimsuffix(var.domain_name, ".${replace(var.domain_name, "/^[^\\.]+\\./", "")}")
  type    = "CNAME"
  value   = aws_lb.this.dns_name
  ttl     = var.cloudflare_record_ttl
  proxied = false

  depends_on = [aws_lb.this]
}

resource "aws_route53_record" "app_domain" {
  count = var.domain_provider == "route53" && var.acm_certificate_arn == "" ? 1 : 0

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.this.dns_name]

  depends_on = [aws_lb.this]
}

# Listener for HTTPS
resource "aws_lb_listener" "https" {
  depends_on = [
    aws_acm_certificate_validation.this
  ]

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn != "" ? var.acm_certificate_arn : aws_acm_certificate.this[0].arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Vaultwarden ALB is active."
      status_code  = "200"
    }
  }
}

# Listener for HTTP (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
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
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
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
  vpc_id          = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  public_subnets  = var.create_vpc ? aws_subnet.this_public[*].id : var.public_subnet_ids
  private_subnets = var.create_vpc ? aws_subnet.this_private[*].id : var.private_subnet_ids
  cluster_arn     = var.create_cluster ? aws_ecs_cluster.this[0].arn : var.cluster_arn
}

# ------------------------------
# RDS: PostgreSQL Database
# ------------------------------

resource "aws_db_subnet_group" "this" {
  name       = "${var.vpc_name}-db-subnet-group"
  subnet_ids = local.private_subnets

  tags = merge(
    {
      Name        = "${var.vpc_name}-db-subnet-group"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_db_instance" "this" {
  identifier              = "${var.vpc_name}-postgres"
  engine                  = "postgres"
  engine_version          = "18"
  instance_class          = var.db_instance_type
  allocated_storage       = var.db_storage_gb
  max_allocated_storage   = var.db_max_storage_gb
  publicly_accessible     = false
  storage_encrypted       = true
  deletion_protection     = true
  multi_az                = var.db_multi_az
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  username                = var.db_username
  password                = random_password.db.result
  skip_final_snapshot     = true
}

# Store RDS password securely in Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name = "${var.vpc_name}-rds-password"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.db.result
}

# Generate secure random DB password
resource "random_password" "db" {
  length  = 20
  special = true
  override_special = "_%@"
}

resource "aws_security_group" "db_sg" {
  name        = "${var.vpc_name}-db-sg"
  description = "Allow access from ECS tasks to PostgreSQL"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [for cidr in var.private_subnets : cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${var.vpc_name}-db-sg"
      Environment = var.environment
      Terraform   = "true"
    },
    var.tags
  )
}
