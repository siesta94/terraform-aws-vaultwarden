# Terraform AWS Vaultwarden Module

This Terraform module provides everything you need to **self-host Vaultwarden** — a lightweight password manager compatible with Bitwarden clients — either:

- **Inside your existing AWS infrastructure** (by using `create_vpc = false` and providing an existing `vpc_id`)
- **Or by spinning up a completely new one** (by setting `create_vpc = true`)

## Overview

This module automates deployment of Vaultwarden components within AWS using ECS, EFS, IAM, and networking resources.  
It is designed for flexibility — you can integrate it with your current VPC or let the module create all required infrastructure for you.

### Key Features

- Conditional VPC creation with subnets, routes, and gateways  
- Secure ECS deployment of Vaultwarden  
- EFS integration for data persistence  
- IAM roles for proper ECS task execution  
- Easily customizable variables for environment settings

## Example Usage

You can deploy Vaultwarden either in an existing VPC and ECS cluster or let the module create completely new ones.

```hcl
module "vaultwarden" {
  source         = "github.com/siesta94/terraform-aws-vaultwarden"

  # Toggle VPC creation (set false to use existing VPC)
  create_vpc     = true
  vpc_id         = null
  vpc_cidr       = "10.1.0.0/16"
  vpc_name       = "vaultwarden-example-vpc"

  # Toggle ECS cluster creation (set false to use existing cluster)
  create_cluster = true
  cluster_arn    = null
  cluster_name   = "vaultwarden-example"

  # Subnet definitions
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]

  environment = "example"
  tags = {
    Project     = "vaultwarden"
    Environment = "example"
  }
}

output "vpc_id" {
  value = module.vaultwarden.vpc_id
}

output "ecs_cluster_arn" {
  value = module.vaultwarden.ecs_cluster_arn
}
```

This configuration demonstrates full flexibility — users can spin up both networking and ECS layers or integrate Vaultwarden directly with existing AWS infrastructure.

---

**Author:** @siesta94  
**License:** MIT
