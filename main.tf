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


resource "aws_lambda_function" "get_all_authors" {
  function_name    = "get-all-authors"
  filename         = "${path.module}/lambda.zip"
  handler          = "get-all-authors.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}

resource "aws_lambda_function" "get_all_courses" {
  function_name    = "get-all-courses"
  filename         = "${path.module}/lambda.zip"
  handler          = "get-all-courses.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}

resource "aws_lambda_function" "get_course" {
  function_name    = "get-course"
  filename         = "${path.module}/lambda.zip"
  handler          = "get-course.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}

resource "aws_lambda_function" "save_course" {
  function_name    = "save-course"
  filename         = "${path.module}/lambda.zip"
  handler          = "save-course.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}

resource "aws_lambda_function" "update_course" {
  function_name    = "update-course"
  filename         = "${path.module}/lambda.zip"
  handler          = "update-course.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}

resource "aws_lambda_function" "delete_course" {
  function_name    = "delete-course"
  filename         = "${path.module}/lambda.zip"
  handler          = "delete-course.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}

