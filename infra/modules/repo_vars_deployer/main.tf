terraform {
  required_providers {
    bitbucket = {
      source  = "zahiar/bitbucket"
      version = "1.6.0"
    }
  }
}
data "bitbucket_repository" "this" {
  workspace = var.org_workspace
  name      = var.repo_name
}
resource "bitbucket_deployment" "this" {
  workspace   = data.bitbucket_repository.this.workspace
  repository  = data.bitbucket_repository.this.name
  name        = terraform.workspace
  environment = var.stage
}

resource "bitbucket_deployment_variable" "this" {
  for_each   = {for idx, variable in var.deployment_variables : idx => variable}
  workspace  = data.bitbucket_repository.this.workspace
  repository = data.bitbucket_repository.this.name
  deployment = bitbucket_deployment.this.id
  key        = each.value.key
  value      = each.value.value
  secured    = true
}

resource "bitbucket_pipeline_variable" "this" {
  for_each   = {for idx, variable in var.pipelines_variables : idx => variable}
  workspace  = data.bitbucket_repository.this.workspace
  repository = data.bitbucket_repository.this.name
  key        = each.value.key
  value      = each.value.value
  secured    = true
}
