variable "aws_region" {}
variable "site_domain" {}

variable "ci_user" {
  default = ""
}

variable "enable_cloudfront" {
  default = false
}

variable "acm_certificate_arn" {}

variable "not_found_response_path" {
  default = "/index.html"
}
