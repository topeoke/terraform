provider "aws" {
  profile = "default"
  region = "eu-west-2"
}
resource "aws_instance" "instance1" {
  ami = "ami-0d8e27447ec2c8410"
  instance_type = "t2-micro"
  key_name = "packetlaneLondonReg-KeyPairs"

  tags = {
    Name = "instance1"
  }
}

output "InstanceID" {
  value = "${aws_instance.instance1.id}"
}