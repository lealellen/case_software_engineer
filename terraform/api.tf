resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "case_api"
  protocol_type = "HTTP"
  body          = file("${path.module}/../api/api.yaml") 
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
}
