output "lambda_arn" {
    value = aws_lambda_function.this.arn
}

output "signer_name" {
    value = aws_signer_signing_profile.this.name
}