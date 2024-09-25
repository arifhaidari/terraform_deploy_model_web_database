resource "aws_ebs_volume" "datascientest-ebs" {
  availability_zone = var.availability_zone
  size = var.ebs_size

  tags = {
    Name = "datascientest-ebs"
  }
}

resource "aws_volume_attachment" "datascientest_ebs_att" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.datascientest-ebs.id
  instance_id = aws_instance.datascientest-instance.id
}

