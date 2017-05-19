variable "balanced_servers_name" {
  type = "string"
}

variable "balanced_servers_subnets" {
  type = "list"
}

variable "balanced_servers_instance_type" {
  type = "string"
}

variable "azs" {
  type = "list"
}

variable "vpc_id" {
  type = "string"
}
