output "db_endpoint" {
    value = aws_db_instance.mysql.address
}

output "db_name" {
    value = aws_db_instance.mysql.db_name
}

output "db_username" {
    value = aws_db_instance.mysql.username
}

output "db_password" {
    value = aws_db_instance.mysql.password
}

output "db_engine_version" {
    value = aws_db_instance.mysql.engine_version
}