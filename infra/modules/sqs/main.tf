resource "aws_sqs_queue" "this" {
    region                    = var.region
    name                      = var.name
    delay_seconds             = 90
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
    redrive_policy = jsonencode({
        deadLetterTargetArn = var.dlq_arn
        maxReceiveCount     = 4
    })

    kms_master_key_id = var.kms_id
}

data "aws_iam_policy_document" "this" {
    statement {
        sid    = "${var.name}_sns"
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = ["sns.amazonaws.com"]
        }

        actions = [
            "SQS:SendMessage",
        ]

        resources = [
            aws_sqs_queue.this.arn,
        ]

        condition {
            test     = "ArnEquals"
            variable = "aws:SourceArn"

            values = [
                var.sns_topic_arn
            ]
        }
    }
}

resource "aws_sqs_queue_policy" "this" {
    queue_url = aws_sqs_queue.this.id
    policy = data.aws_iam_policy_document.this.json
}

resource "aws_sns_topic_subscription" "this" {
    topic_arn = var.sns_topic_arn
    protocol  = "sqs"
    endpoint  = aws_sqs_queue.this.arn
}