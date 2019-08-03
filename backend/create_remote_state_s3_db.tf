provider "aws" {
  region = "${var.region}"
  profile = "default"
}

resource "aws_s3_bucket" "InfrastructureRemoteStateBucket" {
  bucket = "${var.remote_state_bucket}"
  region = "${var.region}"
  acl = "${var.remote_state_bucket_acl}"

  versioning {
    enabled = "true"
  }
  tags = {
    Name = "Infras-Remote-States"
  }
}

resource "aws_dynamodb_table" "packetlane-state-lock" {
  hash_key = "LockID"
  name = "${var.remote_state_dynamoDB_table}"
  write_capacity = 1
  read_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }
}
