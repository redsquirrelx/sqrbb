resource "aws_sns_topic" "reserva_proc" {
    name = "reserva_proc_topic"
    kms_master_key_id = aws_kms_key.kms["us-east-2"].id
}

resource "aws_sqs_queue" "error" {
    name                      = "error_sqs"
    kms_master_key_id = aws_kms_key.kms["us-east-2"].id
}

module "stats_sqs" {
    source = "./modules/sqs"
    region = "us-east-2"

    sns_topic_arn = aws_sns_topic.reserva_proc.arn
    name = "stats_sqs"
    dlq_arn = aws_sqs_queue.error.arn
    kms_id = aws_kms_key.kms["us-east-2"].id
}

module "reserva_mail_sqs" {
    source = "./modules/sqs"
    region = "us-east-2"

    sns_topic_arn = aws_sns_topic.reserva_proc.arn
    name = "reserva_mail_sqs"
    dlq_arn = aws_sqs_queue.error.arn
    kms_id = aws_kms_key.kms["us-east-2"].id
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.error.id

    redrive_allow_policy = jsonencode({
        redrivePermission = "byQueue",
        sourceQueueArns   = [
            module.stats_sqs.sqs_arn,
            module.reserva_mail_sqs.sqs_arn
        ]
    })
}