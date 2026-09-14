data "aws_ami" "amazon_linux" {

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

}

resource "aws_instance" "bootstrap" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = true

  iam_instance_profile = var.instance_profile_name

  key_name = "key-f3"

  user_data = templatefile("${path.module}/bootstrap.sh.tpl", {

    postgres_databases = var.postgres_databases
    username           = var.postgres_credentials.username
    password           = var.postgres_credentials.password

    auth_sql      = var.postgres_sql_files.auth
    flag_sql      = var.postgres_sql_files.flag
    targeting_sql = var.postgres_sql_files.targeting

  })

  tags = {
    Name = "db-bootstrap"
  }

}
