#I'll be creating 2 repositories one for PHP and another for Nginx
resource "aws_ecr_repository" "app_repo" {
    name            = "${var.app_name}-${var.environment}-php"
    force_delete    = var.environment == "dev" ? true : false
}

resource "aws_ecr_repository" "nginx_repo" {
    name            = "${var.app_name}-${var.environment}-nginx"
    force_delete    = var.environment == "dev" ?true : false
}

resource "aws_cloudwatch_log_group" "logs" {
    name                = "/ecs/${var.app_name}-${var.environment}"
    retention_in_days   = var.environment == "dev" ? 7 : 30
}

resource "aws_security_group" "loadbalancer_sg" {
    name        = "${var.app_name}-${var.environment}-loadbalancer-sg"
    description = "Security group for loadbalancer. Allows HTTP traffic from internet."
    vpc_id      = var.vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "main" {
    name                = "${var.app_name}-${var.environment}-alb"
    load_balancer_type  = "application"
    internal            = false
    subnets             = var.public_subnet_ids
    security_groups     = [aws_security_group.loadbalancer_sg.id]
}

resource "aws_lb_target_group" "app" {
    name = "${var.app_name}-${var.environment}-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
    deregistration_delay = 30
    target_type = "ip"
    health_check {
        path = "/" 
    } 
}

resource "aws_lb_listener" "front_end" {
    load_balancer_arn   = aws_lb.main.arn
    port                = "80"
    protocol            = "HTTP"
    default_action {
        type            = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}

resource "aws_ecs_cluster" "main" {
    name = "${var.app_name}-${var.environment}-cluster"
    tags = {
        Name = "${var.app_name}-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_ecs_task_definition" "app" {
    family                  = "${var.app_name}-${var.environment}-task"
    execution_role_arn      = aws_iam_role.ecs_execution_role.arn
    task_role_arn           = aws_iam_role.ecs_task_role
    network_mode            = "awsvpc"
    cpu                     = var.fargate_cpu
    memory                  = var.fargate_memory
    requires_compatibilities = ["FARGATE"]
    container_definitions = jsonencode([
        {
            "name": "${var.app_name}-${var.environment}-nginx",
            "image": "${aws_ecr_repository.nginx_repo.repository_url}:${var.app_image_tag}",
            "essential": true
            "portMappings": [{
                "containerPort": 80
            }],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": aws_cloudwatch_log_group.logs.name
                    "awslogs-region": "${var.aws_region}"
                    "awslogs-stream-prefix": "nginx"
                }
            
            }
            depends_on      = [{
                "containerName": "${var.app_name}-${var.environment}-php",
                "condition": "START"
            }]
        },
        {
            name        = "php"
            image       = "${aws_ecr_repository.app_repo.repository_url}:${var.app_image_tag}"
            essential   = true
            logConfiguration = {
                logDriver   = "awslogs",
                options     = {
                    "awslogs-group": "${aws_cloudwatch_log_group.logs.name}",
                    "awslogs-region": "${var.aws_region}",
                    "awslogs-stream-prefix": "php"
                }
            }
        }
    ])
}
resource "aws_ecs_service" "main" {
    name            = "${var.app_name}-${var.environment}-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"

    network_configuration {
        security_groups = [aws_security_group.ecs_tasks_sg.id]
        subnets         = var.private_subnet_ids
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.app.arn
        container_name   = "${var.app_name}-${var.environment}-nginx"
        container_port   = 80
    }
    depends_on = [
        aws_lb_listener.front_end, 
        aws_iam_role_policy_attachment.ecs_execution_policy]
}

resource "aws_security_group" "ecs_tasks_sg" {
    name            = "${var.app_name}-${var.environment}-ecs-tasks-sg"
    description     = "Allow traffic from ALB only"
    vpc_id          = var.vpc_id
    ingress {
        protocol            = "tcp"
        from_port           = 80
        to_port             = 80
        security_groups     = [aws_security_group.loadbalancer_sg.id] 
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.app_name}-${var.environment}-ecs-tasks-sg"
        Environment = var.environment
    }
}