output "security_group_id" {
  description = "ID of the security group for web servers"
  value       = aws_security_group.web.id
}

output "server_port" {
  description = "Port that the security group allows"
  value       = var.server_port
}
