variable "api_name" {}
/*
(Required) List of endpoint types. This resource currently only supports managing a single value.
 Valid values: EDGE, REGIONAL or PRIVATE. If unspecified, defaults to EDGE.
If set to PRIVATE recommend to set put_rest_api_mode = merge to not cause the endpoints
 and associated Route53 records to be deleted.
 Refer to the documentation for more information on the difference between edge-optimized and regional APIs.
 */
variable "api_type" {
  description = "how to serve the API"
  default     = "EDGE"
}
variable "api_domain_name" {}
variable "zone_id" {}
variable "partition" {}
variable "allowed_origins" {
  type = list(string)
  default = ["http://localhost:3000", "https://yafa.dev"]
}

variable "apis_config" {
  type = list(object({
    path_part = string
    methods = list(object({
      http_method       = string
      function_name     = string
      lambda_invoke_arn = string
    }))
  }))
}

