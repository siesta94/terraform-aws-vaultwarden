# examples/basic/main.tf
#
# Fully parameterized example calling the Vaultwarden module

terraform {
  required_version = ">= 1.6.0"

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

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "vaultwarden" {
  source = "../../modules/vaultwarden"

  # General configuration
  aws_region  = var.aws_region
  environment = var.environment
  tags        = var.tags

  # Networking
  create_vpc      = var.create_vpc
  vpc_cidr        = var.vpc_cidr
  vpc_name        = var.vpc_name
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # ECS cluster
  create_cluster = var.create_cluster
  cluster_name   = var.cluster_name

  # Database
  db_instance_type   = var.db_instance_type
  db_storage_gb      = var.db_storage_gb
  db_max_storage_gb  = var.db_max_storage_gb
  db_multi_az        = var.db_multi_az
  db_username        = var.db_username
  rds_secret_name    = var.rds_secret_name

  # Domain and certificates
  domain_name          = var.domain_name
  domain_provider      = var.domain_provider
  acm_certificate_arn  = var.acm_certificate_arn
  cloudflare_zone_id   = var.cloudflare_zone_id
  cloudflare_record_ttl = var.cloudflare_record_ttl
  cloudflare_api_token = var.cloudflare_api_token

  # Vaultwarden application configuration
  vaultwarden_image_tag = var.vaultwarden_image_tag
  vaultwarden_extra_env = var.vaultwarden_extra_env
}