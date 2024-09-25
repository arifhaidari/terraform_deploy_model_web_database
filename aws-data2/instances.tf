resource "aws_instance" "datascientest-instance" {
  ami = var.image_id # only available in eu-west-3 region
  instance_type = var.type_instance # instance size (1vcpu, 1G ram)
  key_name = "datascientest_keypair"
  monitoring = var.monitoring
   network_interface {
   network_interface_id = aws_network_interface.interface_reseau_instance.id
   device_index = 0
  }
  tags = {
    Name = "datascientest" #instance tag
  }
}
# vpc creation for resources
resource "aws_vpc" "datascientest_vpc" {
  cidr_block = var.cidr_block_vpc[0]

  tags = {
    Name = "datascientest_vpc"
  }
}
# create subnet for resources
resource "aws_subnet" "datascientest_subnet" {
  vpc_id = aws_vpc.datascientest_vpc.id
  cidr_block = var.cidr_block_subnet[0]
  availability_zone = var.availability_zone

  tags = {
    Name = "datascientest_subnet"
  }
}

resource "aws_network_interface" "interface_reseau_instance" {
  subnet_id = aws_subnet.datascientest_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "interface_reseau_instance"
  }
}