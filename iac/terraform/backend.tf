terraform {

  backend "s3" {

    bucket       = "s3-fiap-712979978195"
    key          = "tf-f3/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
