variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "medusa_image" {
  description = "Docker image for Medusa"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT Secret for authentication"
  type        = string
  sensitive   = true
}
