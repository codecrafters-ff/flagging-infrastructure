##############################################
# SECRETS MODULE VARIABLES
# modules/secrets/variables.tf
##############################################

variable "sa_password" {
  type     = string
  nullable = true
  default  = null
}
variable "admin_key" {
  type     = string
  nullable = true
  default  = null
}
variable "redis_password" {
  type     = string
  nullable = true
  default  = null
}
variable "ghcr_token" {
  type     = string
  nullable = true
  default  = null
}
variable "backend_environment" {
  type        = string
  description = "env label for SSM path tags"
}