resource "aws_s3_bucket" "gds-paas-releases" {
  bucket        = "${var.releases_bucket_name}"
  acl           = "public-read"
  force_destroy = "true"
}
