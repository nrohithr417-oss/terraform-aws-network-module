########################################
# Current AWS Account
########################################

data "aws_caller_identity" "current" {}

########################################
# Customer-Managed KMS Key
########################################

resource "aws_kms_key" "terraform_backend" {
  description             = "KMS key for Terraform state and DynamoDB lock table"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name      = "terraform-backend-kms-key"
    ManagedBy = "Terraform"
  }
}

resource "aws_kms_alias" "terraform_backend" {
  name          = "alias/terraform-backend"
  target_key_id = aws_kms_key.terraform_backend.key_id
}

########################################
# Terraform State S3 Bucket
########################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "Terraform Remote State"
    ManagedBy = "Terraform"
  }
}

########################################
# State Bucket Public Access Protection
########################################

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

########################################
# State Bucket Ownership
########################################

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

########################################
# State Bucket Versioning
########################################

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# State Bucket KMS Encryption
########################################

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_backend.arn
    }

    bucket_key_enabled = true
  }
}

########################################
# Access Logs Bucket
########################################

# This bucket is the final access-log destination.
# Enabling logging on it would create recursive access logs.
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "access_logs" {
  bucket = "${var.bucket_name}-access-logs"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "Terraform State Access Logs"
    ManagedBy = "Terraform"
  }
}

########################################
# Access Logs Public Access Protection
########################################

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

########################################
# Access Logs Bucket Ownership
########################################

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

########################################
# Access Logs Bucket Versioning
########################################

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# Access Logs Bucket Encryption
########################################

# The S3 server-access-log destination uses SSE-S3 encryption.
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

########################################
# Access Logs Lifecycle
########################################

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  depends_on = [
    aws_s3_bucket_versioning.access_logs
  ]

  rule {
    id     = "access-log-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

########################################
# Access Logs Bucket Policy
########################################

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowS3ServerAccessLogs"
        Effect = "Allow"

        Principal = {
          Service = "logging.s3.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.access_logs.arn}/terraform-state-access/*"

        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.terraform_state.arn
          }

          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.access_logs.arn,
          "${aws_s3_bucket.access_logs.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.access_logs,
    aws_s3_bucket_ownership_controls.access_logs
  ]
}

########################################
# Enable State Bucket Access Logging
########################################

resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "terraform-state-access/"

  depends_on = [
    aws_s3_bucket_policy.access_logs
  ]
}

########################################
# State Bucket Security Policy
########################################

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.terraform_state,
    aws_s3_bucket_server_side_encryption_configuration.terraform_state
  ]
}

########################################
# DynamoDB Terraform Lock Table
########################################

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_backend.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "Terraform State Lock"
    ManagedBy = "Terraform"
  }
}