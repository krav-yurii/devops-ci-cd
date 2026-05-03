terraform {
  backend "s3" {
    bucket       = "krav-yurii-devops-final-project-tfstate"
    key          = "final-project/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    encrypt      = true
    profile      = "default"
  }
}
