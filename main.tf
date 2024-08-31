provider "aws" {
  region = "ap-southeast-1"
}

# Create IAM role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name   = "lambda-logging-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }]
    })
  }
}

# Lambda function 
resource "aws_lambda_function" "user_api_function" {
  function_name = "UserApiFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "user_lambda_function.lambda_user_function"
  runtime       = "python3.9"

  filename = "lambda.zip"

  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "UserApiGateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.user_api_function.invoke_arn
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /users"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_api_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

output "api_url" {
  value = aws_apigatewayv2_api.api_gateway.api_endpoint
}