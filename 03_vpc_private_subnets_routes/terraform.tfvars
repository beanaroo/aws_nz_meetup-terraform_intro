# ---- Control VPC ----

vpc_cidr = "10.0.0.0/16"

vpc_name = "control"

nat_gateways = "3"

azs = [
  "a",
  "b",
  "c",
]

public_subnets = [
  "10.0.96.0/19",
  "10.0.128.0/19",
  "10.0.160.0/19",
]

private_subnets = [
  "10.0.0.0/19",
  "10.0.32.0/19",
  "10.0.64.0/19",
]
