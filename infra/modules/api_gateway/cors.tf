# https://www.linkedin.com/pulse/terraform-amazon-api-gateway-cors-ahmad-ferdaus-abd-razak
resource "aws_api_gateway_method" "this_options" {
  for_each      = aws_api_gateway_resource.this
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this_options" {
  for_each = aws_api_gateway_method.this_options
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.this[each.key].id
  http_method          = aws_api_gateway_method.this_options[each.key].http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates    = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_model" "this_model" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = "user"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = jsonencode({
    type = "object"
  })
}

resource "aws_api_gateway_method_response" "options_response_200" {
  for_each = aws_api_gateway_method.this_options
  rest_api_id     = aws_api_gateway_rest_api.this.id
  resource_id     = aws_api_gateway_resource.this[each.key].id
  http_method     = aws_api_gateway_method.this_options[each.key].http_method
  status_code     = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}


resource "aws_api_gateway_integration_response" "cors_response" {
  for_each = aws_api_gateway_method.this_options
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.this_options[each.key].http_method
  status_code = aws_api_gateway_method_response.options_response_200[each.key].status_code

  response_templates = {
    "application/json" = "$input.json('$.body')"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}


resource "aws_api_gateway_gateway_response" "cors_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS'"
  }
  lifecycle {
    ignore_changes = [response_templates]
  }
}

resource "aws_api_gateway_gateway_response" "cors_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "DEFAULT_5XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS'"
  }

  lifecycle {
    ignore_changes = [response_templates]
  }
}