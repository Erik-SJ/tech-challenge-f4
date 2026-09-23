terraform {

  backend "s3" {

    bucket       = "s3-fiap-071200285218"
    key          = "tf-f4/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
