# modules/vaultwarden/variables.tf

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of an existing VPC to use if create_vpc is false"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "The CIDR block for the new VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name to assign to the new VPC"
  type        = string
  default     = "vaultwarden-vpc"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "environment" {
  description = "Environment tag (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "create_cluster" {
  description = "Whether to create a new ECS cluster"
  type        = bool
  default     = true
}

variable "cluster_arn" {
  description = "Existing ECS cluster ARN, used when create_cluster is false"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Name prefix for ECS cluster to create"
  type        = string
  default     = "vaultwarden-cluster"
}