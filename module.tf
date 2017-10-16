resource "aws_iam_policy" "bucket-policy" {
  name  = "bucket-${var.site_domain}-policy"
  count = "${var.ci_user ? 1 : 0}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "${aws_s3_bucket.bucket.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "${aws_s3_bucket.bucket.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "bucket-policy-attach" {
  count      = "${var.ci_user ? 1 : 0}"
  user       = "${var.ci_user}"
  policy_arn = "${aws_iam_policy.bucket-policy.arn}"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.site_domain}"
  acl           = "public-read"
  region        = "${var.aws_region}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags {
    Name = "${var.site_domain}"
  }
}

// Create a Cloudfront distribution for the static website
resource "aws_cloudfront_distribution" "website_cdn" {
  count               = "${var.enable_cloudfront ? 1 : 0}"
  enabled             = true
  price_class         = "PriceClass_200"
  http_version        = "http1.1"
  default_root_object = "index.html"

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.bucket.id}"
    domain_name = "${aws_s3_bucket.bucket.website_endpoint}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "200"
    response_page_path    = "${var.not_found_response_path}"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl          = "0"
    default_ttl      = "300"                                      //3600
    max_ttl          = "1200"                                     //86400
    target_origin_id = "origin-bucket-${aws_s3_bucket.bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  aliases = ["${var.site_domain}"]
}
