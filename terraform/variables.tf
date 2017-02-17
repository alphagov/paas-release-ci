# SAH256 of the account IDs. To get it, run:
#
#   echo -n 1234567890 | sha256sum
#
# being 1234567890 the account id
variable "account_ids_sha256" {
  default = {
    "19cadd55dbfd1ec914844038f4089e612cbde5621351059a6c86aecbf1407eb9" = "ci"
    "1e4087ea54eb2a9028f10da2598225415b0437cde3ce88d666f39b2906925126" = "dev"
  }
}

variable "deploy_env" {}

variable "region" {
  default = "eu-west-1"
}

variable "releases_bucket_name" {
  description = "Name of the bucket to store the created releases"
}

variable "releases_blobs_bucket_name" {
  description = "Name of the bucket to store source blobs"
}
