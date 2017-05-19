##------------- Multi_AZ VPC Module --------------##

# Our control VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name        = "${var.vpc_name}-vpc-uw2"
    Provisioner = "terraform"
  }
}

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

##------------- Subnets --------------##

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

# ---- NEW ----

# Private subnet in each AZ
resource "aws_subnet" "private" {
  count             = "${length(var.private_subnets)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${format("%s%s", var.region, var.azs[count.index])}"

  tags {
    Name = "${var.vpc_name}-${element(var.azs, count.index)}-private-subnet"
  }

  map_public_ip_on_launch = "false"
}

##------------- Routing --------------##

##-- Public --##

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.main.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]

  tags {
    Name = "${var.vpc_name}-${var.region}-public-rt"
  }
}

# Associate "public" subnets with "public" route table.
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Route default to internet gateway (used by NAT gateway)
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main_igw.id}"
}

##-- Private --##

# Route Table for private subnets
resource "aws_route_table" "private" {
  count            = "${length(var.private_subnets)}"
  vpc_id           = "${aws_vpc.main.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]

  tags {
    Name = "${var.vpc_name}-${element(var.azs, count.index)}-private-rt"
  }
}

# Associate "private" subnets with "private" route table.
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# Route default to NAT gateway
resource "aws_route" "private_nat_gateway" {
  count                  = "${length(var.private_subnets)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.main_natgw.*.id, count.index)}"
}

