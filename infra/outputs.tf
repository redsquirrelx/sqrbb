output "cloudfront-dist-id" {
    value = module.frontend.cloudfront-dist-id
}

output "aws-account-id" {
    value = data.aws_caller_identity.current.account_id
}