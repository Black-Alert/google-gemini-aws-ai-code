data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "this" {
  name = "${var.api_name}-${terraform.workspace}"
  endpoint_configuration {
    types = [var.api_type]
  }
  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_api_gateway_resource" "this" {
  for_each = {for idx, val in var.apis_config : val.path_part => val}

  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
  rest_api_id = aws_api_gateway_rest_api.this.id
}

data "aws_api_gateway_resource" "this_resource" {
  for_each    = {for idx, val in var.apis_config : val.path_part => val}
  rest_api_id = aws_api_gateway_rest_api.this.id
  path        = "/${each.value.path_part}"
  depends_on = [aws_api_gateway_resource.this]
}

locals {
  methods_flat = flatten([
    for api in var.apis_config : [
      for method in api.methods : {
        path_part         = api.path_part
        http_method       = method.http_method
        function_name     = method.function_name
        lambda_invoke_arn = method.lambda_invoke_arn
      }
    ]
  ])
}

resource "aws_api_gateway_method" "this_post" {
  for_each = {
    for idx, method in local.methods_flat : "${method.path_part}-${method.http_method}" => method
  }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.value.path_part].id
  http_method   = each.value.http_method
  authorization = "NONE"
  depends_on = [
    aws_api_gateway_resource.this,
    data.aws_api_gateway_resource.this_resource
  ]
}

resource "aws_api_gateway_integration" "this" {
  for_each = {
    for idx, method in local.methods_flat : "${method.path_part}-${method.http_method}" => method
  }

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this[each.value.path_part].id
  http_method             = each.value.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_invoke_arn

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [
    aws_api_gateway_method.this_post,
    aws_lambda_permission.apigw_lambda
  ]
}
resource "aws_lambda_permission" "apigw_lambda" {
  for_each = {
    for idx, method in local.methods_flat : "${method.path_part}-${method.http_method}" => method
  }

  statement_id  = "${each.value.function_name}APIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method, and resource path within API Gateway
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
}


resource "random_string" "unique_suffix" {
  length  = 4
  special = false
  lower   = true
  upper   = false
}

resource "aws_api_gateway_method_response" "response_200" {
  for_each = {
    for idx, method in local.methods_flat : "${method.path_part}-${method.http_method}" => method
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.value.path_part].id
  http_method = each.value.http_method
  status_code = "200"
  depends_on = [
    aws_api_gateway_method.this_post,
    aws_api_gateway_integration.this
  ]
}

resource "aws_api_gateway_integration_response" "this_200" {
  for_each = {
    for idx, method in local.methods_flat : "${method.path_part}-${method.http_method}" => method
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.value.path_part].id
  http_method = each.value.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "$input.json('$.body')"
  }
  depends_on = [
    aws_api_gateway_method.this_post,
    aws_api_gateway_integration.this
  ]
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.this
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode([
      [for key in keys(aws_api_gateway_resource.this) : aws_api_gateway_resource.this[key].id],
      [for key in keys(aws_api_gateway_method.this_post) : aws_api_gateway_method.this_post[key].id],
      [for key in keys(aws_api_gateway_integration.this) : aws_api_gateway_integration.this[key].id],
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = terraform.workspace
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this.domain_name
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "ERROR"
    metrics_enabled    = true
    data_trace_enabled = true
  }

  depends_on = [aws_api_gateway_account.this]
}
