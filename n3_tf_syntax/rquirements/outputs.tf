# these variables are used when the execution is done and the resources are proviesioned 
# and we get some values from the result such as assigned ip address. 

output "instance_ip_addr" {
  value = aws_instance.instance.private_ip
}

output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}