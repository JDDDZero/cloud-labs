provider "aws" {
  region = var.region
}

resource "aws_dynamodb_table" "authors" {
  name         = "authors"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "courses" {
  name         = "courses"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec" {
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
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*",
          "dynamodb:*"
        ],
        Resource = "*"
      }
    ]
  })
}

locals {
  lambda_runtime = "nodejs16.x"
  lambda_zip     = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "get_all_authors" {
  function_name    = "get-all-authors"
  filename         = local.lambda_zip
  handler          = "get-all-authors.handler"
  runtime          = local.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256(local.lambda_zip)
}

resource "aws_lambda_function" "get_all_courses" {
  function_name    = "get-all-courses"
  filename         = local.lambda_zip
  handler          = "get-all-courses.handler"
  runtime          = local.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256(local.lambda_zip)
}

resource "aws_lambda_function" "get_course" {
  function_name    = "get-course"
  filename         = local.lambda_zip
  handler          = "get-course.handler"
  runtime          = local.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256(local.lambda_zip)
}

resource "aws_lambda_function" "save_course" {
  function_name    = "save-course"
  filename         = local.lambda_zip
  handler          = "save-course.handler"
  runtime          = local.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256(local.lambda_zip)
}

resource "aws_lambda_function" "update_course" {
  function_name    = "update-course"
  filename         = local.lambda_zip
  handler          = "update-course.handler"
  runtime          = local.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256(local.lambda_zip)
}

resource "aws_lambda_function" "delete_course" {
  function_name    = "delete-course"
  filename         = local.lambda_zip
  handler          = "delete-course.handler"
  runtime          = local.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256(local.lambda_zip)
}

resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "API for Cloud Labs Lambda functions"
}

resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "courses"
}

resource "aws_api_gateway_resource" "course_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.courses.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_courses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_courses_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.get_courses.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_all_courses.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_invoke_get_courses" {
  statement_id  = "AllowAPIGatewayInvokeGetCourses"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_courses.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "get_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.get_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_course.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_invoke_get_course" {
  statement_id  = "AllowAPIGatewayInvokeGetCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "save_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "save_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.save_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.save_course.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_invoke_save_course" {
  statement_id  = "AllowAPIGatewayInvokeSaveCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "update_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.update_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_course.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_invoke_update_course" {
  statement_id  = "AllowAPIGatewayInvokeUpdateCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "delete_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.delete_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_course.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_invoke_delete_course" {
  statement_id  = "AllowAPIGatewayInvokeDeleteCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "options_courses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_courses_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.options_courses.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_courses_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.options_courses.http_method
  status_code = "200"
  depends_on = [
  aws_api_gateway_method.options_courses,
  aws_api_gateway_integration.options_courses_integration,
]


  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "options_courses_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.options_courses.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.get_courses_integration,
    aws_api_gateway_integration.get_course_integration,
    aws_api_gateway_integration.save_course_integration,
    aws_api_gateway_integration.update_course_integration,
    aws_api_gateway_integration.delete_course_integration,
    aws_api_gateway_integration_response.options_courses_integration_response
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = timestamp()
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}
