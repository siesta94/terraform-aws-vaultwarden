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

```hcl
module "vaultwarden" {
  source     = "github.com/siesta94/terraform-aws-vaultwarden"
  create_vpc = true

  vpc_cidr        = "10.1.0.0/16"
  vpc_name        = "vaultwarden-example-vpc"
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]

  environment = "example"
}
```

This example creates a new VPC, subnets, and all necessary resources to deploy Vaultwarden in AWS ECS.

---

**Author:** @siesta94  
**License:** MIT