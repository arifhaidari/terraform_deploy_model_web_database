output "datascientest-instance_ip_public" {
  value = aws_instance.datascientest-instance.public_ip #returns the public ip of the datascientest instance
}