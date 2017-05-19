# ---- Control VPC ----

vpc_cidr = "10.0.0.0/16"

vpc_name = "control"

nat_gateways = "3"

public_subnets = [
  "10.0.0.96.0/19",
  "10.0.0.128.0/19",
  "10.0.0.160.0/19",
]

azs = [
  "a",
  "b",
  "c",
]
