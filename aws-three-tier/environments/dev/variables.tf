variable "environment" {
    description = "name of the environment where the deployment happens" #(e.g = dev or prod)
    type        = string
}

variable "app_name" {
    description = "value"
    type        = string
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "public_subnets_cidr" {
    description = "list of the CIDR blocks for the public subnets"
    type        = list(string)
}

variable "private_subnets_cidr" {
    description = "list of the CIDR blocks for the private subnets"
    type        = list(string)
}

variable "availability_zones" {
    description = "ist of availability zones to deploy into"
    type        = list(string)
}

variable "aws_region" {
    description = "The AWS region to deploy the resources into (for example, us-east-1 or eu-west-1)."
    type        = string
}

variable "db_instance_class" {
    description = "the instance type"
    type        = string 
}

variable "db_password" {
    description = "password for the database"
    type        = string
    sensitive   = true
}

variable "fargate_cpu" {
    description = "value"
    type        = number
}

variable "fargate_memory" {
    description = "value"
    type        = number 
}

variable "app_count" {
    description = "value"
    type        = number
}

variable "app_image_tag" {
    description = "Tag of the docker image to deploy"
    type        = string
    default     = "latest"
}

variable "github_repo_owner" {
    description = "GitHub username"
    type        = string
}

variable "github_repo_name" {
  description = "GitHub Repository Name"
  type        = string
}

variable "github_branch" {
  description = "Branch to trigger off"
  type        = string
}