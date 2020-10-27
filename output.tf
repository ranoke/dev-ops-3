output "server_public_ip_1" {
  value = aws_eip.one.public_ip
}

output "server_public_ip_2" {
  value = aws_eip.two.public_ip
}