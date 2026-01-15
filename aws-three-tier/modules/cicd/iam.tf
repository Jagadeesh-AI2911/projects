resource "aws_iam_role" "codebuild_role" {
    name = "${var.app_name}-${var.environment}-codebuild-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "codebuild.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy" "codebuild_policy" {
    role = aws_iam_role.codebuild_role.name
    policy = jsonencode({
        Version     = "2012-10-17"
        Statement   = [
            {
                Effect  = "Allow"
                Action  = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:GetRespositoryPolicy",
                    "ecr:DescribeRepositories",
                    "ecr:ListImages",
                    "ecr:DescribeImages",
                    "ecr:BatchGetImage",
                    "ecr:InitiateLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:CompleteLayerUpload",
                    "ecr:PutImage"
            ] 
            Resource = [
                var.ecr_php_arn,
                var.ecr_nginx_arn
            ]
            },
            {
                Action = ["ecr:GetAuthorizationToken"]
                Effect = "Allow"
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:PutObject"
                ]
                Resource = "${aws_s3_bucket.codepipeline_bucket.arn}/*"
            },
            {
                Effect = "Allow"
                Action = [
                    "ecs:DescribeServices",
                    "ecs:DescribeTaskDefinition",
                    "ecs:DescribeTasks",
                    "ecs:DescribeClusters",
                    "ecs:ListTasks",
                    "ecs:ListTaskDefinitions",
                    "ecs:UpdateService"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "codepipeline_role" {
    name = "${var.app_name}-${var.environment}-pipeline-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "codepipeline.amazonaws.com"
            }
        }]
    })
    tags = {
        Name = "${var.app_name}-${var.environment}-CodePipeline-Execution-Role"
        Environment = var.environment
        Application = var.app_name
        ManagedBy = "terraform"
    }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
    name = "${var.app_name}-${var.environment}-codepipeline-policy"
    role = aws_iam_role.codepipeline_role.name
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:GetBucketVersioning",
                    "s3:PutObject"
                ]
                Resource = [
                    aws_s3_bucket.codepipeline_bucket.arn,
                    "${aws_s3_bucket.codepipeline_bucket.arn}/*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "codebuild:ListBuilds",
                    "codebuild:ListProjects",
                    "codebuild:ListRepositories",
                    "codebuild:BatchGetBuilds",
                    "codebuild:StartBuild",
                    "codebuild:ListBuildsForProjects",
                    "codebuild:BatchGetProjects"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "ecr:GetAuthorizationToken"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "ecs:DescribeServices",
                    "ecs:DescribeTaskDefinition",
                    "ecs:DescribeTasks",
                    "ecs:ListTasks",
                    "ecs:ListTaskDefinitions",
                    "ecs:RegisterTaskDefinition",
                    "ecs:UpdateService"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "iam:PassRole"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "logs:GetLogEvents"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "codestar-connections:UseConnection"
                ]
                Resource = aws_codestarconnections_connection.github.arn
            }
        ]
    })
}