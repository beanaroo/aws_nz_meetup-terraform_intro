data "aws_ami" "amazon_linux_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2017.03*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "balanced_server" {
  count                   = "${length(var.balanced_servers_subnets)}"
  subnet_id               = "${element(var.balanced_servers_subnets, count.index)}"
  ami                     = "${data.aws_ami.amazon_linux_latest.image_id}"
  instance_type           = "${var.balanced_servers_instance_type}"
  vpc_security_group_ids  = ["${aws_security_group.balanced_servers.id}"]
  disable_api_termination = "false"

  tags {
    Name        = "${var.balanced_servers_name}-${element(var.azs, count.index)}-ec2"
    Provisioner = "terraform"
  }
}

resource "aws_elb" "balanced_ec2" {
  name            = "${var.balanced_servers_name}-elb"
  subnets         = ["${var.balanced_servers_subnets}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                 = ["${aws_instance.balanced_server.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout              = 400

  tags {
    Name        = "${var.balanced_servers_name}-elb"
    Provisioner = "terraform"
  }
}

resource "aws_security_group" "elb" {
  vpc_id      = "${var.vpc_id}"
  name        = "restrict_elb_inbound"
  description = "Authorized IPs only"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["204.23.112.55/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "balanced_servers" {
  vpc_id      = "${var.vpc_id}"
  name        = "restrict_ec2_inbound"
  description = "Allow inbound elb traffic"

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
