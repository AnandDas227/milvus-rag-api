terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "= 1.19.1"
    }
  }
}

# data sources to look up, these are manually configured

# iam token for restapi provider
data "ibm_iam_auth_token" "tokendata" {}

# Look up the pre-existing Code Engine project by GUID
data "ibm_code_engine_project" "ce_project" {
  project_id = var.ce_project_id
}

# Look up the pre-existing Registry secret within the project
data "ibm_code_engine_secret" "registry_secret" {
  project_id = data.ibm_code_engine_project.ce_project.id
  name       = var.ce_registry_secret
}

# Look up the pre-existing Git SSH secret
data "ibm_code_engine_secret" "git_ssh_secret" {
  count      = var.is_private_repo ? 1 : 0
  project_id = data.ibm_code_engine_project.ce_project.id
  name       = var.ce_ssh_secret
}

# Declare locals
locals {
  project_id = data.ibm_code_engine_project.ce_project.id
  # This will change on every terraform apply
  build_timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

# Providers
provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "restapi" {
  uri                  = "https://api.${var.region}.codeengine.cloud.ibm.com/"
  write_returns_object = true
  headers = {
    Authorization = data.ibm_iam_auth_token.tokendata.iam_access_token
  }
}

# Code Engine Build
resource "ibm_code_engine_build" "code_engine_build_instance" {
  project_id         = local.project_id
  name               = "${var.ce_buildname}-${local.build_timestamp}"
  output_image       = "${var.cr}/${var.cr_namespace}/${var.cr_imagename}:${local.build_timestamp}"
  output_secret      = data.ibm_code_engine_secret.registry_secret.name
  source_url         = var.source_url
  source_revision    = var.source_revision
  source_context_dir = var.source_context_dir
  strategy_size      = var.strategy_size 
  strategy_type      = "dockerfile"
  source_secret      = var.is_private_repo ? data.ibm_code_engine_secret.git_ssh_secret[0].name : null
}

# Run Code Engine Build
resource "restapi_object" "buildrun" {
  path = "/v2/projects/${local.project_id}/build_runs"
  data = jsonencode({
    name       = "build-run-${local.build_timestamp}"
    build_name = ibm_code_engine_build.code_engine_build_instance.name
    timeout    = 3600
  })
  id_attribute = "name"
  
  # Force replacement when build timestamp changes
  lifecycle {
    replace_triggered_by = [
      ibm_code_engine_build.code_engine_build_instance.name
    ]
  }
}

# Manual wait time for Code Engine Image Build
resource "time_sleep" "wait_for_build" {
  create_duration = var.create_duration
  triggers = {
    build_run_name = restapi_object.buildrun.id
  }
}

# Deploy Code Engine App
resource "ibm_code_engine_app" "code_engine_app_instance" {
  project_id              = local.project_id
  name                    = var.ce_app_name
  image_reference         = ibm_code_engine_build.code_engine_build_instance.output_image
  image_secret            = data.ibm_code_engine_secret.registry_secret.name
  image_port              = var.ce_app_port
  scale_ephemeral_storage_limit = var.ce_app_ephemeral_storage
  scale_initial_instances = var.ce_app_config_scale_min
  scale_min_instances = var.ce_app_config_scale_min
  scale_max_instances     = var.ce_app_config_scale_max
  scale_memory_limit            = var.ce_app_memory
  scale_cpu_limit              = var.ce_app_cpu

  dynamic "run_env_variables" {
    for_each = var.app_env_vars
    content {
      name  = run_env_variables.key
      value = run_env_variables.value
      type  = "literal"
    }
  }

  depends_on = [
    time_sleep.wait_for_build
  ]
}