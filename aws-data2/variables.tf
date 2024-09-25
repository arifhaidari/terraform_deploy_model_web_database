variable "type_instance" {
  type = string
  default = "t3.micro"
}
variable "image_id" {
  type = string
  nullable = false
}
variable "monitoring" {
  type = bool
  default = false
}
variable "ebs_size" {
  type = number
  default = "5"
}
variable "cidr_block_vpc" {
  type = list
  default = ["172.16.0.0/16"]
}
variable "cidr_block_subnet" {
  type = list
  default = ["172.16.10.0/24"]
}
variable "availability_zone" {
  type = string
  default = "eu-west-3a"
}