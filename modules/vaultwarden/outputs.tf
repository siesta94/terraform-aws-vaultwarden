# modules/vaultwarden/outputs.tf

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

# ------------------------------
# Vaultwarden Module Extended Outputs
# ------------------------------

output "vaultwarden_alb_dns_name" {
  description = "DNS name of the Application Load Balancer hosting Vaultwarden"
  value       = aws_lb.this.dns_name
}

output "vaultwarden_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.vaultwarden.name
}

output "vaultwarden_task_definition" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.vaultwarden.arn
}

output "vaultwarden_efs_id" {
  description = "Vaultwarden EFS filesystem ID"
  value       = aws_efs_file_system.vaultwarden.id
}

output "vaultwarden_backup_vault" {
  description = "AWS Backup vault name for EFS backups"
  value       = aws_backup_vault.vaultwarden.name
}