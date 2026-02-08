# Example usage of the Vaultwarden module

module "vaultwarden" {
  source           = "../../modules/vaultwarden"
  create_vpc       = true
  create_cluster   = true
  vpc_cidr         = "10.1.0.0/16"
  vpc_name         = "vaultwarden-example-vpc"
  environment      = "example" # Use something like "prod"

  public_subnets   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  # RDS Configuration
  db_instance_type   = "db.t4g.micro"
  db_storage_gb      = 20
  db_max_storage_gb  = 100
  db_multi_az        = false
  db_username        = "vaultwarden"
  db_password        = var.vaultwarden_user_password

  tags = {
    Project     = "vaultwarden"
    Environment = "example"
  }
}