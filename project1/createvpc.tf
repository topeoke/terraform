provider "aws" {
  profile = "default"
  region = "${var.region}"
}

terraform {
  backend "s3" {
    key = "${var.backend_key}"
    dynamodb_table = "${var.backend_db_table}"
    bucket = "${var.backend_s3_bucket}"
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