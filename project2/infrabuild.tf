variable "aws_access_key" {}
variable "aws_secret_access_key" {}


provider "aws" {
  region = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_access_key}"
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

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "infrastructureVPC"
  cidr = "${var.cidrVPC}"
  azs = "${data.aws_availability_zones.AZS.names}"

  private_subnets = [
  for item in var.count_private_subnet:
  cidrsubnet("${var.cidrVPC}", 8, item+1)
  ]
  public_subnets = [
  for item in var.count_public_subnet:
  cidrsubnet("${var.cidrVPC}", 8, item+10)
  ]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Enviroment = "${terraform.workspace}"

  }

  }


