variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vaultwarden_user_password" {
  description = "Optional admin password for Vaultwarden setup (if required)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "API token for the Cloudflare account (must have DNS edit permissions)"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare Zone ID for the domain (used for DNS record creation and ACM validation)"
  type        = string
  sensitive   = false
}
