output "db_name" {
    value = aws_db_instance.rds-app-prod.name
}

output "db_host" {
    value = aws_db_instance.rds-app-prod.address
}

output "db_username" {
    value = aws_db_instance.rds-app-prod.username
}
