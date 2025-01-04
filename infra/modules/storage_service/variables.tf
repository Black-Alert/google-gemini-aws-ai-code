variable "storage_name" {}
variable "bucket_acl" {
  default     = "private"
  description = "tell if the bucket is private or public possible values: 1. private, 2. public-read"
}
variable "is_public" {
  default     = false
  description = "check if the buket is public or private"
}

variable "cors_enabled" {
  default     = false
  description = "to enable CORS configs in an S3 bucket"
}
variable "is_cloud_front" {
  default     = false
  description = "Cloudfront doesn't support KMS encryption for S3"
}

variable "default_region" {
  default = "me-central-1"
}
#variable "allowed_origins" {
#  type        = list(string)
#  description = "provide a list of allowed cors origins"
#  default     = ["*"]
#}
#variable "allowed_methods" {
#  type        = list(string)
#  description = "allowed methods: PUT, POST"
#  default     = ["GET", "PUT", "POST"]
#}

variable "cors_configs" {
  type = object({
    allowed_headers : optional(list(string))
    allowed_origins : optional(list(string))
    allowed_methods : optional(list(string))
    expose_headers : optional(list(string))
    max_age_seconds : optional(number)
  })

  default = null
}