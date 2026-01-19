resource "aws_codestarconnections_connection" "github" {
    name = "${var.app_name}-${var.environment}-github-connection"
    provider_type = "GitHub"
    tags = {
        Name        = "${var.app_name}-${var.environment}-github-connection"
        Environment = "${var.environment}"
    }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
    bucket          = "${var.app_name}-${var.environment}-pipeline-atifacts-bkt"
    force_destroy   = var.environment == "dev" ? true : false
    tags            = {
        Name        = "${var.app_name}-${var.environment}-pipeline-artifacts-bkt"
        Environment = "${var.environment}"
    }
}

resource "aws_codebuild_project" "docker_build" {
    name            = "${var.app_name}-${var.environment}-build-project"
    description     = "this codebuild project builds Docker image and pushes to ECR"
    service_role    = aws_iam_role.codebuild_role.arn
    build_timeout   = "10"
    artifacts   {
        type        = "CODEPIPELINE"
    }
    environment {
        compute_type    = "BUILD_GENERAL1_SMALL"
        image           = var.build_image_version
        type            = "LINUX_CONTAINER"
        privileged_mode = true

        environment_variable {
            name        = "ECR_REPO_URL"
            value       = var.ecr_repository_url
        }
        environment_variable {
            name        = "AWS_DEFAULT_REGION"
            value       = "us-east-1"
        }
        environment_variable {
            name        = "CONTAINER_NAME"
            value       = var.container_name
        }
        environment_variable {
            name        = "ECR_REPO_URL_PHP"
            value       = var.ecr_php_url
        }
        environment_variable {
            name        = "ECR_REPO_URL_NGINX"
            value       = var.ecr_nginx_url 
        }
    }

    source {
        type        = "CODEPIPELINE"
        buildspec   = "php-app-repo/buildspec.yml"
    }
}

resource "aws_codepipeline" "pipeline" {
    name            = "${var.app_name}-${var.environment}-pipeline"
    role_arn        = aws_iam_role.codepipeline_role.arn
    artifact_store {
        location    = aws_s3_bucket.codepipeline_bucket.bucket 
        type        = "S3"
    }
    stage {
        name                        = "Source"
        action  {
            name                    = "Source"
            category                = "Source"
            owner                   = "AWS"
            provider                = "CodeStarSourceConnection"
            version                 = "1"
            output_artifacts        = ["source_output"]
            configuration           = {
                ConnectionArn       = aws_codestarconnections_connection.github.arn
                FullRepositoryId    = "${var.github_repo_owner}/${var.github_repo_name}"
                BranchName          = var.github_branch
            }
        }
    }

    stage {
        name                    = "Build"
        action {
            name                = "Build"
            category            = "Build"
            owner               = "AWS"
            provider            = "CodeBuild"
            version             = "1"
            input_artifacts     = ["source_output"]
            output_artifacts    = ["build_output"]
            configuration       = {
                ProjectName     = aws_codebuild_project.docker_build.name
            }
        }
    }
    stage {
        name                    = "Deploy"
        action {
            name                = "Deploy"
            category            = "Deploy"
            owner               = "AWS"
            provider            = "ECS"
            version             = "1"
            input_artifacts     = ["build_output"]
            configuration       = {
                ClusterName     = var.ecs_cluster_name
                ServiceName     = var.ecs_service_name
                FileName        = "imagedefinition.json"
            }
        }
    }
}

resource "aws_codebuild_project" "infra_deploy" {
    name            = "${var.app_name}-${var.environment}-infra-deploy-project"
    description     = "this codebuild project deploys infrastructure using terraform"
    service_role    = aws_iam_role.codebuild_role.arn
    build_timeout   = "10" 
    artifacts   {
        type        = "CODEPIPELINE"
    }
    environment {
        compute_type    = "BUILD_GENERAL1_SMALL"
        image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
        type            = "LINUX_CONTAINER"
        privileged_mode = true

        environment_variable {
            name        = "TF_VAR_app_name"
            value       = var.app_name
        }
        environment_variable {
            name        = "TF_VAR_environment"
            value       = var.environment
        }
        environment_variable {
            name        = "TF_VAR_github_repo_owner"
            value       = var.github_repo_owner
        }
        environment_variable {
            name        = "TF_VAR_github_repo_name"
            value       = var.github_repo_name
        }
        environment_variable {
            name        = "TF_VAR_github_branch"
            value       = var.github_branch
        }
        environment_variable {
            name        = "TF_VAR_ecs_cluster_name"
            value       = var.ecs_cluster_name
        }
        environment_variable {
            name        = "TF_VAR_ecs_service_name"
            value       = var.ecs_service_name
        }
        environment_variable {
            name        = "TF_VAR_container_name"
            value       = var.container_name
        }

        environment_variable {
            name        = "TF_VAR_db_password"
            value       = "TemporaryPassword!" 
        }
    }

    source {
        type        = "CODEPIPELINE"
        buildspec   = "aws-three-tier/buildspec-infra.yml"
    }
}

resource "aws_codepipeline" "infra_pipeline" {
    name            = "${var.app_name}-${var.environment}-infra-pipeline"
    role_arn        = aws_iam_role.codepipeline_role.arn
    artifact_store {
        location    = aws_s3_bucket.codepipeline_bucket.bucket 
        type        = "S3"
    }
    stage {
        name                        = "Source"
        action  {
            name                    = "Source"
            category                = "Source"
            owner                   = "AWS"
            provider                = "CodeStarSourceConnection"
            version                 = "1"
            output_artifacts        = ["infra_source"]
            configuration           = {
                ConnectionArn       = aws_codestarconnections_connection.github.arn
                FullRepositoryId    = "${var.github_repo_owner}/${var.github_repo_name}"
                BranchName          = var.github_branch
            }
        }
    }

    stage {
        name                    = "Terraform_Apply"
        action {
            name                = "Terraform_Apply"
            category            = "Build"
            owner               = "AWS"
            provider            = "CodeBuild"
            version             = "1"
            input_artifacts     = ["infra_source"]
            configuration       = {
                ProjectName     = aws_codebuild_project.infra_deploy.name
            }
        }
    }
}