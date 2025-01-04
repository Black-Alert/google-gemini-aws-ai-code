module "chat_ai_lambda" {
  source        = "./modules/lambda"
  function_name = "ai_chat_lambda"

  lambda_env_vars = {
    GEMINI_API_KEY = "AIzaSyASaJyFntD94_buNg3h_vobQQTnOqC6J48"
  }

  role_arn      = module.lambda_execution_role.role_arn
  runtime       = "python3.12"
  bucket_id     = module.lambda_build_storage.bucket_id
}

module "lambda_build_storage" {
  source       = "./modules/storage_service"
  storage_name = "blacl-alert-demos-lambdas-build-storage"
}

module "lambda_execution_role" {
  source    = "./modules/iam"
  role_name = "black_alert_lambdas_role_${terraform.workspace}"

  service_assumptions = [
    {
      service    = "lambda.amazonaws.com"
      policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    }
  ]
}

