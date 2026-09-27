terraform {
  backend "s3" {
    bucket       = "terraform-state-297580067361"
    key          = "tf-layered-infra/web/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}
