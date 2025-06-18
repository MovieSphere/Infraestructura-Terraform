output "auth_db_address" {
  value = aws_db_instance.auth_db.address
}

output "users_db_address" {
  value = aws_db_instance.users_db.address
  }

output "catalog_db_address" {
  description = "Dirección del host de la base de datos de catálogo"
  value = aws_db_instance.catalog_db.address
}