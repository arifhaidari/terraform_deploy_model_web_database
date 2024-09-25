resource "aws_security_group" "datascientest-sg" {
  name = "datascientest-sg"
  description = "Allows incoming traffic on ports 80, 443 and 22 and all outgoing traffic"

  ingress { #inbound traffic
    description = "Allow incoming traffic on port 443"
    from_port = 443 #source port
    to_port = 443 #destination port
    protocol = "tcp" #protocol
    cidr_blocks = ["0.0.0.0/0"] #source address, no restriction. Possible to connect from anywhere
  }
  ingress { #incoming traffic
    description = "Allow incoming traffic on port 80"
    from_port = 80 #source port
    to_port = 80 #destination port
    protocol = "tcp" #protocol
    cidr_blocks = ["0.0.0.0/0"] #source address, no restrictions. Possible to connect from anywhere
  }
    ingress { #incoming traffic
    description = "Allow incoming traffic on port 22"
    from_port = 22 #source port
    to_port = 22 #destination port
    protocol = "tcp" #protocol
    cidr_blocks = ["0.0.0.0/0"] #source address, no restrictions. Possible to connect from anywhere
  }
  egress { #outgoing traffic
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "datascientest-sg"
  }
}

resource "aws_network_interface_sg_attachment" "datascientest_sg_attachment" {
  security_group_id = aws_security_group.datascientest-sg.id
  network_interface_id = aws_instance.datascientest-instance.primary_network_interface_id
}
