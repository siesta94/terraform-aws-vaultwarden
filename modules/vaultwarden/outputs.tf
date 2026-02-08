# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC (created or provided)"
  value       = local.vpc_id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster (created or provided)"
  value       = local.cluster_arn
}

output "rds_endpoint" {
  description = "The endpoint of the PostgreSQL RDS instance"
  value       = aws_db_instance.this.address
}

output "rds_username" {
  description = "The master username for the PostgreSQL database"
  value       = var.db_username
  sensitive   = true
}
