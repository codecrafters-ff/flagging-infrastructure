##############################################
# DEVELOPMENT ENVIRONMENT VARIABLES
# env/dev/frontend/variables.tf
##############################################
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "af-south-1"
}

# variable "backend_environment" {
#   description = "The environment (frontend) to deploy resources"
#   type        = string
# }

# variable "sa_password" {
#   description = "SQL SA password for development"
#   type        = string
#   sensitive   = true
# }

# variable "redis_password" {
#   description = "Redis password for development"
#   type        = string
#   sensitive   = true
# }

# variable "admin_key" {
#   description = "Admin API key for development"
#   type        = string
#   sensitive   = true
# }

variable "ghcr_token" {
  description = "GHCR token"
  type        = string
  sensitive   = true
}

# variable "key_name" {
#   description = "EC2 key pair name for SSH access (optional)"
#   type        = string
#   default     = null
# }

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into EC2 (22)"
  type        = list(string)
}

variable "allowed_api_cidrs" {
  description = "List of CIDR blocks allowed to reach API (8080)"
  type        = list(string)
}
