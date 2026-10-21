variable "project_name" {
  description = "Nom du projet AWS"
  type        = string
  default     = "aws-ha-architecture"
}

variable "vpc_cidr" {
  description = "Plage IPv4 du VPC"
  type        = string
  default     = "10.0.0.0/16"
}
