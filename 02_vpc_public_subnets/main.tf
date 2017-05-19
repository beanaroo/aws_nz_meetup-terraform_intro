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

# ---- NEW ----

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name}-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "main_nateip" {
  count = "${var.nat_gateways}"
  vpc   = true
}

# NAT Gateway(s)
resource "aws_nat_gateway" "main_natgw" {
  count         = "${var.nat_gateways}"
  allocation_id = "${element(aws_eip.main_nateip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.main_igw"]
}

# Public subnet in each AZ
resource "aws_subnet" "public" {
  count             = "${length(var.public_subnets)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_subnets[count.index]}"
  availability_zone = "${format("%s%s", var.region, var.azs[count.index])}"

  tags {
    Name = "${var.vpc_name}-${element(var.azs, count.index)}-public-subnet"
  }

  map_public_ip_on_launch = "false"
}
