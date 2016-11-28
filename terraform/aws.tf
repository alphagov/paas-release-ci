provider "aws" {
  region = "${var.region}"
}

# Guard to prevent operating on an unintended account.
# This code will check that the sha256 of the current account_id is listed
# in the variable var.account_ids_sha256
data "aws_caller_identity" "current" {}

data "null_data_source" "check_aws_account_id_hash" {
  inputs = {
    valid = "${lookup(var.account_ids_sha256, sha256(data.aws_caller_identity.current.account_id))}"
  }
}
