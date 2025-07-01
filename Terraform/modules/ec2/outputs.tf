output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.ec2_ubuntu_docker.id
}

output "private_ip" {
  description = "IP privada de la instancia EC2"
  value       = aws_instance.ec2_ubuntu_docker.private_ip
}

output "public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.ec2_ubuntu_docker.public_ip
}

output "public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.ec2_ubuntu_docker.public_dns
}

output "ec2_public_ip" {
  description = "IP pública estática asociada a la EC2"
  value       = aws_eip.ec2_public_ip.public_ip
}