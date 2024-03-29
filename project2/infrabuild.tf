variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "packetlane-infrastructure-bucket"
    key = "infrastuctureBuild.tfstate"
    dynamodb_table = "packectlane-state-lock-table"
  }
}

data "aws_availability_zones" "AZS" {
  state = "available"
}

resource "aws_s3_bucket" "loadbalancer_log" {
  bucket = "packet-lane-loadbalancer-logs"
  region = "${var.region}"
  acl = "private"
  policy = "${file("lbS3BucketPolicy.json")}"
  force_destroy = true

  tags = {
    Terraform = "true"
    Environment  = "${terraform.workspace}"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "infrastructure-VPC-${terraform.workspace}"
  cidr = "${var.cidrVPC}"
  azs = "${data.aws_availability_zones.AZS.names}"

  private_subnets = [
  for item in range("${var.count_private_subnet}"):
  cidrsubnet("${var.cidrVPC}", 8, item+1)
  ]
  public_subnets = [
  for item in range("${var.count_public_subnet}"):
  cidrsubnet("${var.cidrVPC}", 8, item+10)
  ]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Enviroment = "${terraform.workspace}"
    Name = "Infrastructure-VPC-${terraform.workspace}"

  }

  }

resource "aws_security_group" "management_sg" {
  name = "managementSG"
  description = "Security Group Allowing management access via SSH"
  vpc_id = "${module.vpc.vpc_id}"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22

    cidr_blocks = [
      "${var.allowall}"]
  }


  tags = {
    Name = "Management-SG-${terraform.workspace}"
    Environment = "${terraform.workspace}"
    Terraform = "true"
  }
}

resource "aws_security_group" "webserver_sg" {
  name = "webserverSG"
  description = "Security Group allowing web traffic"
  vpc_id = "${module.vpc.vpc_id}"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80

    cidr_blocks = [
      "${var.allowall}"]
    }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443

    cidr_blocks = [
      "${var.allowall}"]
    }


  tags = {
    Name = "WebServer-SG-${terraform.workspace}"
    Environment = "${terraform.workspace}"
    Terraform = "true"
  }
}

resource "aws_security_group" "database_sg" {
  name = "databaseSG"
  description = "Security Group for database access"
  vpc_id = "${module.vpc.vpc_id}"
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306

    security_groups = ["${aws_security_group.webserver_sg.id}","${aws_security_group.management_sg.id}"]
  }

  tags = {
    Name = "Database-SG-${terraform.workspace}"
    Environment = "${terraform.workspace}"
    Terraform = "true"
  }

}

resource "aws_lb" "infrastructure_lb" {
  name               = "infrastructureLB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.webserver_sg.id}"]
  subnets = "${module.vpc.public_subnets}"


  access_logs {
    bucket  = "${aws_s3_bucket.loadbalancer_log.bucket}"
    prefix  = "Infra-loadbalancer-lb"
    enabled = true
  }

  tags = {
    Name = "Infrastructure-LB-${terraform.workspace}"
    Environment = "${terraform.workspace}"
  }
}