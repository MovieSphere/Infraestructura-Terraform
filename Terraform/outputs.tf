# Este recurso define la salida de la VPC principal para el entorno AWS.
output "vpc_id" {
  description = "ID de la VPC principal"
  value = aws_vpc.main.id
}

# Este recurso define la salida de la tabla de rutas pública para el entorno AWS.
output "public_subnet_route_table" {
  description = "Tabla de rutas pública"
  value = aws_route_table.public
}

# Este recurso define la salida de la subred pública para el entorno AWS.
output "public_subnet_ids" {
  description = "IDs de las subredes públicas"
  value = aws_subnet.public[*].id
}

# Este recurso define la salida de la subred privada para el entorno AWS.
output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value = aws_subnet.private[*].id
}

# Este recurso define la salida de la puerta de enlace de internet para el entorno AWS.
output "internet_gateway_id" {
  description = "ID de la puerta de enlace de internet"
  value = aws_internet_gateway.gw.id
}
