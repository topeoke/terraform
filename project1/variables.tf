variable "region" {
  default = "eu-west-2"
}

variable "ami" {
  description = "AMI to be installed on the EC2 instance"
  default = "ami-0d8e27447ec2c8410"
}

variable "instance_type" {
  description = "EC2 instance type"
  default = "t2.micro"
}

variable "key_name" {
  description = "KeyPair name to be used at  instance creation"
  default = "packetlaneLondonReg-KeyPairs"
}

