variable "rds_password" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.rds_password) >= 8
    error_message = "The RDS password must be at least 8 characters long."
  }
}