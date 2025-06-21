provider "aws" {
  region = "sa-east-1" # ou sua região preferida
}

# Cria o S3
resource "aws_s3_bucket" "lambda_code" {
  bucket = "case-lambda-code-bucket"
}

# Faz o upload do zip da lambda p S3
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "lambda/lambda.zip"
  source = "${path.module}/../lambda/lambda.zip"
  etag   = filemd5("${path.module}/../lambda/lambda.zip")
}

######################### UPLOAD DAS CAMADAS DA LAMBDA NO S3 ################### 
resource "aws_s3_object" "layer_code" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "sklearn_layer/layer.zip"
  source = "${path.module}/../layers/scikit_learn/layer.zip"
  etag   = filemd5("${path.module}/../layers/scikit_learn/layer.zip")
}

resource "aws_s3_object" "scipy_layer" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "scipy_layer/layer.zip"
  source = "${path.module}/../layers/scipy/layer.zip"
  etag   = filemd5("${path.module}/../layers/scipy/layer.zip")
}

resource "aws_s3_object" "joblib_layer" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "joblib_layer/layer.zip"
  source = "${path.module}/../layers/joblib/layer.zip"
  etag   = filemd5("${path.module}/../layers/joblib/layer.zip")
}

resource "aws_s3_object" "threadpoolctl_layer" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "threadpoolctl_layer/layer.zip"
  source = "${path.module}/../layers/threadpoolctl/layer.zip"
  etag   = filemd5("${path.module}/../layers/threadpoolctl/layer.zip")
}

######################### CRIACAO DAS CAMADAS DA LAMBDA ################### 
resource "aws_lambda_layer_version" "scipy_layer" {
  layer_name          = "scipy_layer"
  compatible_runtimes = ["python3.11"]
  s3_bucket           = aws_s3_bucket.lambda_code.id
  s3_key              = aws_s3_object.scipy_layer.key
  source_code_hash    = filebase64sha256("${path.module}/../layers/scipy/layer.zip")
}

resource "aws_lambda_layer_version" "sklearn_layer" {
  layer_name          = "sklearn_layer"
  compatible_runtimes = ["python3.11"]
  s3_bucket           = aws_s3_bucket.lambda_code.id
  s3_key              = aws_s3_object.layer_code.key
  source_code_hash    = filebase64sha256("${path.module}/../layers/scikit_learn/layer.zip")
}

resource "aws_lambda_layer_version" "joblib_layer" {
  layer_name          = "joblib_layer"
  compatible_runtimes = ["python3.11"]
  s3_bucket           = aws_s3_bucket.lambda_code.id
  s3_key              = aws_s3_object.joblib_layer.key
  source_code_hash    = filebase64sha256("${path.module}/../layers/joblib/layer.zip")
}

resource "aws_lambda_layer_version" "threadpoolctl_layer" {
  layer_name          = "threadpoolctl_layer"
  compatible_runtimes = ["python3.11"]
  s3_bucket           = aws_s3_bucket.lambda_code.id
  s3_key              = aws_s3_object.threadpoolctl_layer.key
  source_code_hash    = filebase64sha256("${path.module}/../layers/threadpoolctl/layer.zip")
}

# Lambda Function
resource "aws_lambda_function" "case_software_engineer" {
  function_name    = "case_software_engineer"
  s3_bucket        = aws_s3_bucket.lambda_code.id
  s3_key           = aws_s3_object.lambda_code.key
  source_code_hash = filebase64sha256("${path.module}/../lambda/lambda.zip")
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec.arn
  layers           = [
    aws_lambda_layer_version.sklearn_layer.arn,
    "arn:aws:lambda:sa-east-1:770693421928:layer:Klayers-p311-numpy:14",
    aws_lambda_layer_version.scipy_layer.arn,
    aws_lambda_layer_version.joblib_layer.arn,
    aws_lambda_layer_version.threadpoolctl_layer.arn,
    ]

  environment {
    variables = {
      TABLE_NAME = "tb_case_software_engineer"
    }
  }
}

# Permissão para API Gateway invocar a Lambda
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.case_software_engineer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

resource "aws_dynamodb_table" "case_table" {
  name         = "tb_case_software_engineer"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "passenger_id"

  attribute {
    name = "passenger_id"
    type = "S"
  }
}
