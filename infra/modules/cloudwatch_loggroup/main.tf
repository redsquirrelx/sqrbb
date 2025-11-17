resource "aws_cloudwatch_log_group" "this" {
    region = var.region
    name = var.name
    retention_in_days = 365
    kms_key_id = var.kms_arn
}