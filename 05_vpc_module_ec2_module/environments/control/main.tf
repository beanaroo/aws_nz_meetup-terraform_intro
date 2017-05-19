# ---- Control VPC ----

# Backend configuration for remote state
terraform {
  backend "s3" {
    bucket  = "aws-nz-meetup-may17"
    profile = "meetup"
    key     = "infrastructure/state/control.tfstate"
    region  = "us-west-2"
  }
}

# AWS default provider
provider "aws" {
  profile = "meetup"
  region  = "${var.region}"
}

# ---- Multi-AZ VPC ----
module "control_multi_az_vpc" {
  source          = "../../modules/multi_az_vpc"
  region          = "${var.region}"
  vpc_name        = "${var.vpc_name}"
  vpc_cidr        = "${var.vpc_cidr}"
  nat_gateways    = "${var.nat_gateways}"
  azs             = "${var.azs}"
  public_subnets  = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"
}

# ---- Load Balanced Servers ----
module "control_balanced_ec2" {
  source                         = "../../modules/balanced_ec2"
  balanced_servers_name          = "${var.vpc_name}-server"
  balanced_servers_subnets       = "${module.control_multi_az_vpc.private_subnets}"
  balanced_servers_instance_type = "${var.balanced_servers_instance_type}"
  azs             = "${var.azs}"
  vpc_id                         = "${module.control_multi_az_vpc.vpc_id}"
}
