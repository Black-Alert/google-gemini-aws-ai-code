variable "apis_domain" {
  default = {
    dev = "apis.blackalert.agency"
  }
}
variable "aws_account" {
  default = {
    dev = "699475944995"
  }
}

data "aws_route53_zone" "black_alert_zone" {
  name = "blackalert.agency."
}

module "api" {
  source          = "./modules/api_gateway"
  api_domain_name = var.apis_domain[terraform.workspace]
  api_name        = "black_alert_restful_apis"
  api_type        = "REGIONAL"
  partition       = var.aws_account[terraform.workspace]
  zone_id         = data.aws_route53_zone.black_alert_zone.zone_id

  apis_config = [
    {
      path_part = "chat",
      methods = [
        {
          http_method       = "POST",
          function_name     = module.chat_ai_lambda.function_name,
          lambda_invoke_arn = module.chat_ai_lambda.function_invoke_arn,
        }
      ],
    },
  ]
}
