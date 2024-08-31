output "lambda_function_name" {
  value = aws_lambda_function.user_api_function.function_name
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.api_gateway.api_endpoint
}