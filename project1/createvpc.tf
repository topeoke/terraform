provider "aws" {
  region = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_access_key}"
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

  tags = {
    Name = "instance1"
    env = "${terraform.workspace}"
  }
}

output "InstanceID" {
  value = "${aws_instance.instance1.id}"
}