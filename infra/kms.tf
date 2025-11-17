resource "aws_iam_role" "kms" {
    name = "KMS-Administrators"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "cks.kms.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_kms_key" "kms" {
    for_each = local.all_regions

    region = each.key

    enable_key_rotation = true

    policy = jsonencode({
            Version = "2012-10-17"
            Id      = "kms_policy"
            Statement = [
            {
                Sid = "Enable IAM User Permissions",
                Effect = "Allow",
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                },
                Action = "kms:*",
                Resource = "*"
            },
            {
                Sid    = "Allow administration of the key",
                Effect = "Allow",
                Principal = {
                    AWS = "${aws_iam_role.kms.arn}"
                },
                Action = [
                    "kms:Create*",
                    "kms:Describe*",
                    "kms:Enable*",
                    "kms:List*",
                    "kms:Put*",
                    "kms:Update*",
                    "kms:Revoke*",
                    "kms:Disable*",
                    "kms:Get*",
                    "kms:Delete*",
                    "kms:ScheduleKeyDeletion",
                    "kms:CancelKeyDeletion"
                ],
                Resource = "*",
                Condition = {
                    StringEquals = {
                        "aws:PrincipalAccount" = [ data.aws_caller_identity.current.account_id ]
                    }
                }
            },
            {
                Sid    = "Allow use of the key",
                Effect = "Allow",
                Principal = {
                    Service = [ 
                        "logs.${each.key}.amazonaws.com"
                    ]
                },
                Action = [
                    "kms:Encrypt",
                    "kms:Decrypt",
                    "kms:ReEncrypt*",
                    "kms:GenerateDataKey*",
                    "kms:Describe*"
                ],
                Resource = "*"
            },

        ]
    })
}

resource "aws_kms_key" "dnssec" {
    region = "us-east-1"
  customer_master_key_spec = "ECC_NIST_P256"
  #deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ],
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service",
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Action = "kms:CreateGrant",
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service to CreateGrant",
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}