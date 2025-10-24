output "cloudfront-dist-id" {
    value = module.cloudfront.cloudfront-dist-id
}

output "aws-account-id" {
    value = data.aws_caller_identity.current.account_id
}

output "lmbd-fn-sigv4a-arn" {
    value = module.lambda.lambda-fn-sigv4a.function_name
}

output "cluster-main-name" {
    value = module.services.cluster-main.name
}