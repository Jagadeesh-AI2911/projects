output "alb_hostname" {
    value = aws_lb.main.dns_name
}

output "ecr_php_url" {
    value = aws_ecr_repository.app_repo.repository_url
}

output "ecr_php_name" {
    value = aws_ecr_repository.app_repo.name
}

output "ecr_nginx_url" {
    value = aws_ecr_repository.nginx_repo.repository_url
}

output "ecs_cluster_name" {
    value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
    value = aws_ecs_service.main.name
}

output "ecr_php_arn" {
  value = aws_ecr_repository.app_repo.arn
}

output "ecr_nginx_arn" {
  value = aws_ecr_repository.nginx_repo.arn
}