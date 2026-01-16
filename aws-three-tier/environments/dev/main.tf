terraform {
    backend "s3" {
        bucket  = "terraform-state-locking-jag"
        key     = "dev/terraform.tfstate"
        region  = "us-east-1"
        encrypt = true
    }
}

provider "aws" {
    region = "us-east-1"
}

module "networking" {
    source = "../../modules/networking"

    environment             = var.environment
    vpc_cidr                = var.vpc_cidr
    public_subnets_cidr     = var.public_subnets_cidr
    private_subnets_cidr    = var.private_subnets_cidr
    availability_zones      = var.availability_zones
}

module "database" {
    source = "../../modules/database"

    environment             = var.environment
    vpc_id                  = module.networking.vpc_id
    vpc_cidr                = var.vpc_cidr
    db_instance_class       = var.db_instance_class
    db_password             = var.db_password
    private_subnet_ids      = module.networking.private_subnet_ids
    db_engine_version       = module.database.db_engine_version
}

module "backend" {
    source = "../../modules/backend"
    environment             = var.environment
    app_name                = var.app_name
    vpc_id                  = module.networking.vpc_id
    public_subnet_ids       = module.networking.public_subnet_ids
    private_subnet_ids      = module.networking.private_subnet_ids
    fargate_cpu             = var.fargate_cpu
    fargate_memory          = var.fargate_memory
    app_count               = 1
}

module "frontend" {
    source      = "../../modules/frontend"
    environment = var.environment
    app_name    = var.app_name
}

module "cicd" {
    source                  = "../../modules/cicd"
    environment             = var.environment
    app_name                = var.app_name
    github_repo_owner       = "Jagadeesh-AI2911"
    github_repo_name        = "aws-three-tier"
    github_branch           = "main"
    ecs_cluster_name        = module.backend.ecs_cluster_name
    ecs_service_name        = module.backend.ecs_service_name
    ecr_php_url             = module.backend.ecr_php_url
    ecr_nginx_url           = module.backend.ecr_nginx_url
    ecr_repository_url      = module.backend.ecr_php_url 
    ecr_php_arn             = module.backend.ecr_php_arn
    ecr_nginx_arn           = module.backend.ecr_nginx_arn
}