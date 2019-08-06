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
variable "backend_key" {
  description = "S3 object for the remote state"
  default = "devvelop.tfstate"
}
 variable "backend_db_table" {
   default = "packectlane-state-lock-table"
 }

variable "backend_s3_bucket" {
  default = "packetlane-infrastructure-bucket"
}

variable "allowall" {
  description = "Allowing all hosts"
  default = "0.0.0.0/0"
}