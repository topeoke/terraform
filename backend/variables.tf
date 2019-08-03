variable "region" {
  default = "eu-west-2"
}

variable "remote_state_bucket" {
  description = "Name for the remote state bucket"
  default = "packetlane-infrastructure-bucket"
}

variable "remote_state_dynamoDB_table" {
  description = "The name of ten dynamo DB table"
  default = "packectlane-state-lock-table""
}

variable "remote_state_bucket_acl" {
  description = "ACL for the remote state bucket"
  default = "private"
}