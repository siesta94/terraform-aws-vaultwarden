# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC (created or provided)"
  value       = local.vpc_id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster (created or provided)"
  value       = local.cluster_arn
}
