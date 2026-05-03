# terraform {
#   backend "s3" {
#     bucket       = "krav-yurii-devops-lesson-db-module-tfstate"
#     key          = "lesson-db-module/terraform.tfstate"
#     region       = "eu-north-1"
#     use_lockfile = true
#     encrypt      = true
#     profile      = "default"
#   }
# }
#
