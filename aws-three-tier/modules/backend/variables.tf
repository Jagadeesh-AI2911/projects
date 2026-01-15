variable "environment" {
    description = ""
    type        = string
}

variable "app_name" {
    description = ""
    type        = string
}

variable "vpc_id" {
    description = ""
    type        = string
}

variable "public_subnet_ids" {
    description = ""
    type        = list(string)
}

variable "private_subnet_ids" {
    description = ""
    type        = list(string)
}

variable "fargate_cpu" {
    description = ""
    type        = number
}

variable "fargate_memory" {
    description = ""
    type        = number
}

variable "app_count" {
    description = ""
    type        = number
}

variable "app_image_tag" {
    description = "Tag of the docker image to deploy"
    type        = string
    default     = "latest"
}

variable "aws_region" {
    description = "value"
    type        = string
    default     = "us-east-1"
}