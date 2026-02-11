# modules/vaultwarden/variables.tf

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of an existing VPC to use if create_vpc is false"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "The CIDR block for the new VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name to assign to the new VPC"
  type        = string
  default     = "vaultwarden-vpc"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "environment" {
  description = "Environment tag (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "create_cluster" {
  description = "Whether to create a new ECS cluster"
  type        = bool
  default     = true
}

variable "cluster_arn" {
  description = "Existing ECS cluster ARN, used when create_cluster is false"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Name prefix for ECS cluster to create"
  type        = string
  default     = "vaultwarden-cluster"
}

variable "public_subnet_ids" {
  description = "List of existing public subnet IDs (used when create_vpc = false)"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of existing private subnet IDs (used when create_vpc = false)"
  type        = list(string)
  default     = []
}

# ------------------------------
# RDS PostgreSQL Variables
# ------------------------------

variable "db_instance_type" {
  description = "The instance type for the RDS PostgreSQL database"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_storage_gb" {
  description = "The initial storage size for the RDS database (in GB)"
  type        = number
  default     = 20
}

variable "db_max_storage_gb" {
  description = "The maximum storage size for the RDS database (in GB)"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "The master username for the RDS PostgreSQL database"
  type        = string
  default     = "vaultwarden"
}

# db_password variable is no longer needed since the password is generated and stored automatically in Secrets Manager
# Instead, users can override the secret name if desired
variable "rds_secret_name" {
  description = "Optional custom name for the Secrets Manager secret storing the RDS password"
  type        = string
  default     = null
}

# ------------------------------
# ALB and ACM Variables
# ------------------------------

variable "domain_provider" {
  description = "DNS provider for domain configuration base (cloudflare or route53)"
  type        = string
  default     = "route53"
  validation {
    condition     = contains(["route53", "cloudflare"], var.domain_provider)
    error_message = "domain_provider must be either 'route53' or 'cloudflare'"
  }
}

variable "aws_region" {
  description = "AWS region used for all resources like CloudWatch logs, ECS, and networking"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Primary domain name for Vaultwarden (e.g. vaultwarden.example.com)"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN for HTTPS access (optional)"
  type        = string
  default     = ""
}

# ------------------------------
# Cloudflare Connection Variables
# ------------------------------

variable "cloudflare_api_token" {
  description = "API token for Cloudflare with DNS edit access (required if domain_provider = 'cloudflare')"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Zone ID of the Cloudflare domain (required if domain_provider = 'cloudflare')"
  type        = string
  default     = ""
}

variable "cloudflare_record_ttl" {
  description = "TTL for DNS records managed under Cloudflare"
  type        = number
  default     = 3600
}

# ------------------------------
# Vaultwarden Application Variables
# ------------------------------

variable "vaultwarden_image_tag" {
  description = "Tag of the Vaultwarden Docker image to deploy (e.g. '1.30.5')"
  type        = string
  default     = "latest"
}

variable "vaultwarden_extra_env" {
  description = "Map of additional environment variables for Vaultwarden (e.g. SMTP, DOMAIN, etc.)"
  type        = map(string)
  default     = {}
}
