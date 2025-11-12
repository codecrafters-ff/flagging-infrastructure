##############################################
# SECRETS MODULE VARIABLES
# modules/secrets/variables.tf
##############################################

variable "sa_password" { type = string }
variable "admin_key" { type = string }
variable "redis_password" { type = string }
variable "ghcr_token" { type = string }
variable "backend_environment" {
  description = "The environment for backend secrets"
  type        = string
  default     = "development"
}

variable "frontend_environment" {
  description = "The environment for backend secrets"
  type        = string
  default     = "development"
}
