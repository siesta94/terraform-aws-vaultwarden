# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC (created or provided)"
  value       = local.vpc_id
}