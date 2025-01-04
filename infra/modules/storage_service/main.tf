provider "aws" {
  region = var.default_region
  alias  = "default_region"
  profile = "BA"
}
resource "aws_s3_bucket" "this" {
  bucket = "${var.storage_name}-bucket"
  #  to allow delete none empty buckets
  force_destroy = true

  tags = {
    Name        = "${var.storage_name} bucket"
    Environment = terraform.workspace
  }
  provider = aws.default_region
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.this.id
  count  = var.is_public ? 1 : 0

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://hosting.yafatek.dev", "https://localhost:8035"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }

#   cors_rule {
#     allowed_methods = ["GET"]
#     allowed_origins = ["*"]
#   }
}
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
  provider = aws.default_region
}
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  provider = aws.default_region
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this
  ]

  bucket   = aws_s3_bucket.this.id
  acl      = var.bucket_acl
  provider = aws.default_region
}
resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.is_public ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy = false # Allow public policies
  ignore_public_acls      = false
  restrict_public_buckets = false
  provider                = aws.default_region
}
resource "aws_s3_bucket_cors_configuration" "this" {
  count    = var.cors_enabled ? 1 : 0
  bucket   = aws_s3_bucket.this.id
  provider = aws.default_region

  cors_rule {
    allowed_headers = var.cors_configs.allowed_headers
    allowed_methods = var.cors_configs.allowed_methods
    allowed_origins = var.cors_configs.allowed_origins
    expose_headers  = var.cors_configs.expose_headers
    max_age_seconds = var.cors_configs.max_age_seconds
  }
}

resource "aws_kms_key" "this" {
  count                   = var.is_cloud_front ? 0 : 1
  description             = "${var.storage_name}, used to encrypt bucket objects"
  deletion_window_in_days = 10
  provider                = aws.default_region
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count    = var.is_cloud_front ? 0 : 1
  bucket   = aws_s3_bucket.this.id
  provider = aws.default_region

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_policy" "this" {
  count  = var.is_public && var.is_cloud_front ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
  provider = aws.default_region
}
