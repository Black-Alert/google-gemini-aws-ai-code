
# ai_chat_agent_demo.

module "black_alert_lambda_repo_vars" {
  source        = "./modules/repo_vars_deployer"
  org_workspace = "yafatech"
  repo_name     = "ai_chat_agent_demo"
  deployment_variables = [
    {
      key   = "AWS_ACCESS_KEY_ID"
      value = aws_iam_access_key.this.id
    }, {
      key   = "AWS_SECRET_ACCESS_KEY"
      value = aws_iam_access_key.this.secret
    }, {
      key   = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.id // me-central-1 , us-east-1
    }, {
      key   = "LAMBDA_NAME"
      value = module.chat_ai_lambda.function_name
    }, {
      key   = "ZIP_BUCKET"
      value = module.lambda_build_storage.bucket_id
    }

  ]
  pipelines_variables = [
    {
      key   = "AWS_ACCESS_KEY_ID"
      value = aws_iam_access_key.this.id
    }, {
      key   = "AWS_SECRET_ACCESS_KEY"
      value = aws_iam_access_key.this.secret
    }, {
      key   = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.id
    }, {
      key   = "LAMBDA_NAME"
      value = module.chat_ai_lambda.function_name
    }, {
      key   = "ZIP_BUCKET"
      value = module.lambda_build_storage.bucket_id
    }
  ]
}