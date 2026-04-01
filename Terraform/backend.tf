terraform {
  backend "s3" {
    bucket       = "nader-state-bucket-prod-43721552"
    key          = "project/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}