##############################################
# DEVELOPMENT ENVIRONMENT VARIABLES
# env/dev/frontend/variables.tf
##############################################
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "af-south-1"
}

variable "ghcr_token" {
  description = "GHCR token"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into EC2 (22)"
  type        = list(string)
}

variable "allowed_api_cidrs" {
  description = "List of CIDR blocks allowed to reach API (8080)"
  type        = list(string)
}
