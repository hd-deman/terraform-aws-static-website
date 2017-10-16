output "bucket_arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}

output "bucket_domain_name" {
  value = "${aws_s3_bucket.bucket.bucket_domain_name}"
}

output "website_cdn_hostname" {
  value = "${aws_cloudfront_distribution.website_cdn.domain_name}"
}

output "website_endpoint" {
  value = "${aws_s3_bucket.bucket.website_endpoint}"
}

output "website_domain" {
  value = "${aws_s3_bucket.bucket.website_domain}"
}

output "website_cdn_zone_id" {
  value = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
}

output "website_hosted_zone_id" {
  value = "${aws_s3_bucket.bucket.hosted_zone_id}"
}

output "bucket_name" {
  value = "${aws_s3_bucket.bucket.bucket}"
}
