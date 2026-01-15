provider "aws" {
    region = "var.aws_region"
}

module "networking" {
    source = "../aws-three-tier/modules/networking"

    environment             = var.environment
    vpc_cidr                = var.vpc_cidr
    public_subnets_cidr     = var.public_subnets_cidr
    private_subnets_cidr    = var.private_subnet_ids
    availability_zone       = var.availability_zones
}