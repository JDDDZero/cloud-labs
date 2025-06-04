variable "region" {
  default = "eu-central-1"
}

variable "api_name" {
  default = "clouds-api"
}

variable "lambda_function_name" {
  type = string
}


variable "alert_email" {
  type = string
}
