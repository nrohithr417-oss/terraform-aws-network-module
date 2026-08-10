########################################
# Current AWS Account
########################################

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

########################################
# KMS Key for VPC Flow Logs
########################################

resource "aws_kms_key" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  description             = "KMS key for ${local.name_prefix} VPC Flow Logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"

        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsEncryption"
        Effect = "Allow"

        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }

        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"

        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/${local.name_prefix}/flowlogs"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-flowlogs-kms"
    }
  )
}

########################################
# KMS Alias for VPC Flow Logs
########################################

resource "aws_kms_alias" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name          = "alias/${local.name_prefix}-flowlogs"
  target_key_id = aws_kms_key.vpc_flow_logs[0].key_id
}

########################################
# VPC Flow Logs CloudWatch Log Group
########################################

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "/aws/vpc/${local.name_prefix}/flowlogs"

  # Checkov CKV_AWS_338 requires at least one year.
  retention_in_days = max(var.flow_logs_retention_days, 365)

  kms_key_id = aws_kms_key.vpc_flow_logs[0].arn

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-flowlogs"
    }
  )
}

########################################
# IAM Role for VPC Flow Logs
########################################

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-flowlogs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowVPCFlowLogsAssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }

          ArnLike = {
            "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-flowlogs-role"
    }
  )
}

########################################
# IAM Policy for VPC Flow Logs
########################################

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-flowlogs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "WriteVPCFlowLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
      }
    ]
  })
}

########################################
# VPC Flow Log
########################################

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id = aws_vpc.this.id

  traffic_type = "ALL"

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn

  iam_role_arn = aws_iam_role.flow_logs[0].arn

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-flowlogs"
    }
  )
}