variable "project_name" { type = string }

variable "create_lambda_function_name" {
  type = string
}

variable "retrieve_lambda_function_name" {
  type = string
}

variable "apigw_api_name" {
  type = string
}

variable "apigw_stage_name" {
  type = string
}

variable "alarm_period" {
  type    = number
  default = 300
}

variable "alarm_threshold" {
  type    = number
  default = 1
}
