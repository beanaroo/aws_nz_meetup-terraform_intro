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

variable "nat_gateways" {
  type        = "string"
  description = "Number of nat gateways to create in the VPC"
}

variable "public_subnets" {
  type        = "list"
  description = "A list of public subnets in CIDR notation"
}

variable "azs" {
  type        = "list"
  description = "A list of availability zones to employ"
}
