# Outputs
output "vpc_id" {
  description = "The ID of the created or provided VPC"
  value       = module.vaultwarden.vpc_id
}

output "ecs_cluster_arn" {
  description = "The ARN of the created or provided ECS cluster"
  value       = module.vaultwarden.ecs_cluster_arn
}

output "rds_endpoint" {
  description = "The endpoint of the PostgreSQL RDS instance"
  value       = module.vaultwarden.rds_endpoint
}