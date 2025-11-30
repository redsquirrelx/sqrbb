variable "mrap_arn" {}

variable "bucket_lambda_bucket" {}

variable "bucket_lambda_id" {}

variable "bucket_staticweb_arns" {
    type = list(string)
}

variable "dlq_arn" {}