variable "environment" {
    description = "name of the deployment environment" #e.g = dev or prod
    type        = string
}

variable "vpc_id" {
    description = "the VPC ID where the database will be deployed"
    type        = string
}

variable "private_subnet_ids" {
    description = "list of the private subnet ids for the DB subnet group"
    type        = list(string)
}

variable "vpc_cidr" {
    description = "VPC cidr to allow internal traffic"
    type        = string
}

variable "db_password" {
    description = "master password for the database"
    type        = string
    sensitive   = true
}

variable "db_instance_class" {
    description = "the instance type" #e.g = db.t3.micro for dev and db.r5.large for prod
    type        = string
}

variable "db_engine_version" {
    description = "enter the version of db engine"
    type        = string
}