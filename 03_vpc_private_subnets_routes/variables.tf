# ---- Control VPC ----

variable "region" {
  type        = "string"
  default     = "us-west-2"
  description = "Default AWS region for provider"
}

##------------- VPC --------------##

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

##------------- Subnets --------------##

variable "azs" {
  type        = "list"
  description = "A list of availability zones to employ"
}

variable "public_subnets" {
  type        = "list"
  description = "A list of public subnets in CIDR notation"
}

variable "public_propagating_vgws" {
  type        = "list"
  default     = []
  description = "A list of private subnets in CIDR notation"
}

variable "private_subnets" {
  type        = "list"
  description = "A list of private subnets in CIDR notation"
}

variable "private_propagating_vgws" {
  type        = "list"
  default     = []
  description = "A list of private subnets in CIDR notation"
}
