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

  tags = {
    Terraform = "true"
    Environment  = "${terraform.workspace}"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "infrastructureVPC"
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

  }

  }

resource "aws_security_group" "management_sg" {
  name = "managementSG"
  description = "Security Group Allowing management access via SSH"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22

    cidr_blocks = [
      "${var.allowall}"]
  }


  tags = {

    Environment = "${terraform.workspace}"
    Terraform = "true"
  }
}

resource "aws_security_group" "webserver_sg" {
  name = "webserverSG"
  description = "Security Group allowing web traffic"

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

    Environment = "${terraform.workspace}"
    Terraform = "true"
  }
}

resource "aws_security_group" "database_sg" {
  name = "databaseSG"
  description = "Security Group for database access"
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306

    security_groups = ["${aws_security_group.webserver_sg}","${aws_security_group.management_sg}"]
  }
}

resource "aws_lb" "infrastructure_lb" {
  name               = "infrastructureLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.webserver_sg.id}"]
  subnets = "${module.vpc.public_subnets}"

  access_logs {
    bucket  = "${aws_s3_bucket.loadbalancer_log.bucket}"
    prefix  = "Infra-loadbalancer-lb"
    enabled = true
  }

  tags = {
    Environment = "${terraform.workspace}"
  }
}