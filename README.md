# Terraform AWS Vaultwarden

This module deploys [Vaultwarden](https://github.com/dani-garcia/vaultwarden) on AWS with full infrastructure provisioning.

## Features
- Automated VPC, ECS, and RDS (PostgreSQL)
- ALB with ACM certificate and HTTPS
- DNS automation for both Route53 and Cloudflare
- Secure Secrets Manager integration for credentials

## Usage

```hcl
module "vaultwarden" {
  source = "../../modules/vaultwarden"

  domain_name     = "vaultwarden.example.com"
  domain_provider = "cloudflare"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
}
```

Then run:

```bash
terraform init
terraform apply
```

## Requirements
- Terraform >= 1.6
- AWS credentials configured
- Cloudflare API token with DNS edit permissions