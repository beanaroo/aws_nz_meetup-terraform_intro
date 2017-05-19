# ---- Research VPC ----

vpc_cidr = "10.10.0.0/16"

vpc_name = "research"

nat_gateways = "3"

azs = [
  "a",
  "b",
  "c",
]

public_subnets = [
  "10.10.96.0/19",
  "10.10.128.0/19",
  "10.10.160.0/19",
]

private_subnets = [
  "10.10.0.0/19",
  "10.10.32.0/19",
  "10.10.64.0/19",
]

balanced_servers_instance_type = "t2.micro"
