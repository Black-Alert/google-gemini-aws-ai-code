variable "pipelines_variables" {
  type = list(object({
    key : string
    value : string
  }))
}

variable "deployment_variables" {
  type = list(object({
    key : string
    value : string
  }))
}

variable "org_workspace" {}
variable "repo_name" {}

variable "stage" {
  default     = "Staging"
  description = "expected environment to be one of [Test Staging Production]"
}