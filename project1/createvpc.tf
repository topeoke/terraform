variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  backend "s3" {
    key = "develop.tfstate"
    dynamodb_table = "packectlane-state-lock-table"
    bucket = "packetlane-infrastructure-bucket"
    region = "eu-west-2"
  }
}
resource "aws_instance" "instance1" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = [
  "${aws_security_group.InstanceMGMT.name}"
  ]

  tags = {
    Name = "instance1"
    env = "${terraform.workspace}"
  }
}

resource "aws_security_group" "InstanceMGMT" {
  name = "InstanceMGMT"
  description = "Allowing SSH to Manage the EC2 Instance"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${var.allowall}"]
  }
}

output "InstanceID" {
  value = "${aws_instance.instance1.id}"
}