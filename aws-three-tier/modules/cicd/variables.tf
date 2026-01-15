variable "environment" {
    type        = string
    description = "The environment where this project will be deployed to"
}

variable "app_name" {
    type        = string
    description = "The name of the application"
}

variable "github_repo_owner" {
    type        = string
    description = "The name of the GitHub repository owner"
}

variable "github_repo_name" {
    type        = string
    description = "The name of the GitHub repository"
}

variable "github_branch" {
    type        = string
    description = "The name of the GitHub branch to use for deployment"
}

variable "ecs_cluster_name" {
    type        = string
    description = "The name of the ECS cluster"
}

variable "ecs_service_name" {
    type        = string
    description = "The name of the ECS service"
}

variable "ecr_repository_url" {
    type        = string
    description = "The URL of the ECR repository"
}

variable "container_name" {
    type        = string
    description = "name of the container in the TaskDefinition to update"
    default     = "php"
}

variable "build_image_version" {
    type        = string
    description = "The version of the build image"
    default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
}

variable "codebuild_environment" {
    type        = string
    description = "The compute environment to use for the build"
    default     = "BUILD_GENERAL1_SMALL"  
}

variable "ecr_nginx_url" {
    type        = string
    description = "The URL of the ECR repository for the nginx container"
}

variable "ecr_php_url" {
    type        = string
    description = "The URL of the ECR repository for the php container"
}

variable "ecr_php_arn" {
    type        = string
    description = "The ARN of the ECR repository for the php container"
}

variable "ecr_nginx_arn" {
    type        = string
    description = "The ARN of the ECR repository for the nginx container"
}