resource "aws_s3_bucket" "gds-paas-releases" {
  bucket = "${format("gds-paas-%s-releases", var.deploy_env)}"
  acl = "public-read"
  force_destroy = "true"
}
