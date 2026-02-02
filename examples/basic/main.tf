# Example usage of the VPC module

module "vaultwarden" {
  source       = "../../modules/vaultwarden"
  create_vpc   = true
  create_cluster = true
  vpc_cidr     = "10.1.0.0/16"
  vpc_name     = "vaultwarden-example-vpc"
  environment  = "example" # Use something like "prod"

  public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]

  tags = {
    Project     = "vaultwarden"
    Environment = "example"
  }
}