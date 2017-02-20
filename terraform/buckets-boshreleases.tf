resource "aws_s3_bucket" "gds-paas-releases" {
  bucket        = "${var.releases_bucket_name}"
  acl           = "public-read"
  force_destroy = "true"
}

resource "aws_s3_bucket" "gds-paas-releases-blobs" {
  bucket = "${var.releases_blobs_bucket_name}"
  acl    = "public-read"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
	  "Resource": "arn:aws:s3:::${var.releases_blobs_bucket_name}/*",
      "Principal": { "AWS": ["*"] }
    }
  ]
}
POLICY

  force_destroy = "true"
}
