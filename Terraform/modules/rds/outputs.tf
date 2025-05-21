output "auth_db_address" {
  value = aws_db_instance.auth_db.address
}

output "users_db_address" {
  value = aws_db_instance.users_db.address
}