variable "role_name" {
  type        = string
  description = "Name for the IAM role"
}

variable "service_assumptions" {
  type = list(object({
    service     = string
    policy_arn  = string
  }))
  description = "List of services the role can assume and associated policy ARN"
  default     = []
}


variable "additional_policies" {
  type        = list(string)
  description = "List of additional IAM policy ARNs to attach"
  default     = []
}