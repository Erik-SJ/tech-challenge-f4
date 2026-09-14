aws_region = "us-east-1"

project_name = "fiap-f3"

environment = "lab"

vpc_cidr = "10.0.0.0/22"

availability_zones = [

  "us-east-1a",
  "us-east-1b"

]

public_subnets = [

  "10.0.0.0/25",
  "10.0.0.128/25"

]

private_subnets = [

  "10.0.1.0/25",
  "10.0.1.128/25"

]

redis_subnets = [

  "10.0.2.0/25",
  "10.0.2.128/25"

]

aws_access_key    = ""
aws_secret_key    = ""
aws_session_token = ""