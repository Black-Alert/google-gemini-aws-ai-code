variable "function_name" {
  type        = string
  description = "Name for the Lambda function"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime environment (e.g., python3.9, nodejs16.x)"
  default     = "python3.12"
}

variable "handler" {
  type        = string
  description = "The function within your code package to execute (e.g., portal.handler)"
  default     = "lambda_function.lambda_handler"
}

variable "role_arn" {
  type        = string
  description = "The ARN of the IAM role for the Lambda function"
}

variable "memory_size" {
  type        = number
  description = "Memory for the Lambda function (in MB)"
  default     = 512
}

variable "timeout" {
  type        = number
  description = "Lambda function timeout (in seconds)"
  default     = 120
}

variable "lambda_env_vars" {
  description = "Environment variables for the Lambda function"
  type = map(string)
  default = null
}

variable "bucket_id" {
  description = "Target Code hosting S3 bucket"
}

variable "layers" {
  default = null
}


variable "provisioned_concurrent_executions" {

  description = "The number of provisioned concurrent executions for the Lambda function."
  type        = number
  default     = 1  # Set the default value or adjust as needed
}
variable "is_concurrent" {
  default = false
}