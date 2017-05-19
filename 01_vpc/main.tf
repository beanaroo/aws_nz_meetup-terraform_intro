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

# Our control VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name        = "${var.vpc_name}-vpc-uw2"
    Provisioner = "terraform"
  }
}
