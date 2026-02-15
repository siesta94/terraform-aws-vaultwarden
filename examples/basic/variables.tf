# examples/basic/variables.tf
#
# All variable declarations used by the example module call

variable "aws_region" {
  description = "The AWS region to deploy Vaultwarden into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, stage, prod)"
  type        = string
  default     = "example"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    Project     = "vaultwarden"
    Environment = "example"
  }
}

# Networking
variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block definition"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_name" {
  description = "Name prefix for created VPC"
  type        = string
  default     = "vaultwarden-example-vpc"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
}

# ECS
variable "create_cluster" {
  description = "Whether to create a new ECS cluster"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name prefix for the ECS cluster"
  type        = string
  default     = "vaultwarden-cluster"
}

variable "cluster_arn" {
  description = "Existing ECS cluster ARN (required when create_cluster is false)"
  type        = string
  default     = null
}

variable "log_group_name" {
  description = "Existing CloudWatch log group name (required when create_cluster is false)"
  type        = string
  default     = null
}

# ALB
variable "alb_enable_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
  default     = false
}

variable "alb_ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

# Database
variable "db_instance_type" {
  description = "Instance type for RDS PostgreSQL"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_storage_gb" {
  description = "Allocated RDS storage in GB"
  type        = number
  default     = 20
}

variable "db_max_storage_gb" {
  description = "Maximum RDS storage in GB"
  type        = number
  default     = 100
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "Vaultwarden database username"
  type        = string
  default     = "vaultwarden"
}

variable "db_skip_final_snapshot" {
  description = "Skip final RDS snapshot on destroy"
  type        = bool
  default     = true
}

variable "db_backup_retention_period" {
  description = "RDS automated backup retention in days (0 to disable)"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Daily time range for RDS backups (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "rds_secret_name" {
  description = "Optional name for Secrets Manager password entry"
  type        = string
  default     = "vaultwarden-db-password"
}

# Domain and SSL
variable "domain_provider" {
  description = "DNS provider (cloudflare or route53)"
  type        = string
  default     = "cloudflare"
}

variable "domain_name" {
  description = "Primary FQDN for Vaultwarden access"
  type        = string
  default     = "test-vaultmin.aioc-services.com"
}

variable "route53_zone_id" {
  description = "Existing Route53 hosted zone ID (optional; use for existing cert or multi-level TLDs)"
  type        = string
  default     = null
}

variable "route53_zone_name" {
  description = "Route53 zone name for lookup when zone_id not set (e.g. example.co.uk)"
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN (optional)"
  type        = string
  default     = ""
}

# Cloudflare
variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
}

variable "cloudflare_record_ttl" {
  description = "TTL for Cloudflare-managed DNS records"
  type        = number
  default     = 3600
}

# Vaultwarden Application
variable "vaultwarden_image_tag" {
  description = "Vaultwarden image tag (version pin)"
  type        = string
  default     = "1.34.3"
}

variable "vaultwarden_extra_env" {
  description = "Additional environment variables for Vaultwarden container"
  type        = map(string)
  default = {
    ADMIN_TOKEN      = "change-me"
    SIGNUPS_ALLOWED  = "false"
    ROCKET_WORKERS   = "8"
    SMTP_HOST        = "mail.example.com"
    SMTP_FROM        = "vaultwarden@example.com"
    SMTP_PORT        = "587"
    SMTP_SECURITY    = "starttls"
  }
}
