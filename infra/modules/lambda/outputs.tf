output "lambda-fn-sigv4a" {
    value = aws_lambda_function.sigv4a
}

output "sigv4a-signer-name" {
    value = aws_signer_signing_profile.test_sp.name
}