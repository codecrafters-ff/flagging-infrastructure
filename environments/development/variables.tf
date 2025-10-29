##############################################
# DEVELOPMENT ENVIRONMENT VARIABLES
##############################################
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "af-south-1"
}

variable "sa_password" {
  description = "SQL SA password for development"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Redis password for development"
  type        = string
  sensitive   = true
}

variable "admin_key" {
  description = "Admin API key for development"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "EC2 key pair name for SSH access (optional)"
  type        = string
  default     = null
}
