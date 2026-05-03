variable "jenkins_admin_password" {
  description = "Initial admin password for Jenkins"
  type        = string
  sensitive   = true
  default     = "KravYurii123!"
}

variable "db_password" {
  description = "Master password for the RDS / Aurora database"
  type        = string
  sensitive   = true
  default     = "KravYuriiDb123!"
}
