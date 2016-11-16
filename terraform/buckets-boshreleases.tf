resource "aws_s3_bucket" "gds-paas-boshreleases" {
  bucket = "${format("gds-paas-%s-boshreleases", var.aws_account)}"
  acl = "public-read"
  force_destroy = "true"
}
