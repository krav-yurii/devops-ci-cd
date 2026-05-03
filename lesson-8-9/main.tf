provider "aws" {
  region  = "eu-north-1"
  profile = "default"
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "krav-yurii-devops-lesson-8-9-tfstate"
  table_name  = "krav-yurii-lesson-8-9-terraform-locks"
}

# # Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  vpc_name           = "krav-yurii-lesson-8-9-vpc"
  eks_cluster_name   = "krav-yurii-lesson-8-9-eks"
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "krav-yurii-lesson-8-9-ecr"
  scan_on_push = true
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = "krav-yurii-lesson-8-9-eks"
  cluster_version     = "1.32"
  cluster_subnet_ids  = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  node_subnet_ids     = module.vpc.private_subnets
  node_group_name     = "general"
  node_instance_types = ["t3.medium"]
  desired_size        = 2
  max_size            = 2
  min_size            = 1
}

module "jenkins" {
  source    = "./modules/jenkins"
  namespace = "jenkins"

  admin_user     = "admin"
  admin_password = var.jenkins_admin_password

  depends_on = [module.eks]
}

module "argo_cd" {
  source    = "./modules/argo_cd"
  namespace = "argocd"

  depends_on = [module.eks]
}
