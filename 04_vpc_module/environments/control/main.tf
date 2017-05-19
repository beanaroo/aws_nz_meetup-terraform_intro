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
