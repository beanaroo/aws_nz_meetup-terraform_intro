variable "region" {
  type        = "string"
  default     = "us-west-2"
  description = "Default AWS region for provider"
}

variable "vpc_cidr" {
  type        = "string"
  description = "VPC Address range in CIDR notation"
}

variable "vpc_name" {
  type        = "string"
  description = "VPC Name tag"
}
