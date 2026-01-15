variable "environment" {
    description = "name of the environment where the deployment happens" #(e.g = dev or prod)
    type = string
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type = string
}

variable "public_subnets_cidr" {
    description = "list of the CIDR blocks for the public subnets"
    type = list(string)
}

variable "private_subnets_cidr" {
    description = "list of the CIDR blocks for the private subnets"
    type = list(string)
}

variable "availability_zones" {
    description = "list of availability zones to deploy into"
    type = list(string)
}