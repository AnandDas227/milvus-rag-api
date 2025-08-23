variable "region" {
  description = "Region where Code Engine project will be created"
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  type    = string
  default = "Default"
  description = "Resource group where Code Engine project and application will reside. Must already exist"
}

variable "cr" {
  type    = string
  default = "us.icr.io"
  description = "Container Registry"
}

variable "cr_namespace" {
  type    = string
  default = ""
  description = "Container Registry namespace. Must be between 4 and 24 characters"
}

variable "create_cr_namespace" {
  description = "Set to true to create the Container Registry namespace. If false, it will try to use an existing one."
  type        = bool
  default     = true
}

variable "cr_imagename" {
  type        = string
  description = "Build image"
}

variable "ce_registry_secret" {
  type        = string
  description = "Code Engine registry secret"
}

variable "ce_buildname" {
  type        = string
  description = "Code Engine build name"
}

variable "ce_app_name" {
  type        = string
  description = "Code Engine application name"
}

variable "ce_app_port" {
  type        = number
  description = "Listening port for Code Engine Application"
}

variable "ce_app_ephemeral_storage" {
  type        = string
  description = "Amount of ephemeral storage set for the instance of the app."
}

variable "ce_app_config_scale_min" {
  type        = number
  description = "Minimum number of instances for Code Engine Application"
}

variable "ce_app_config_scale_max" {
  type        = number
  description = "Maximum number of instances for Code Engine Application"
}

variable "source_url" {
  type    = string
  description = "Git repo source name"
}

variable "source_revision" {
  type    = string
  default = "main"
  description = "Git repo branch name"
}

variable "source_context_dir" {
  type    = string
  description = "Subdirectory where Dockerfile and application files are located"
  default = null
}

variable "ibmcloud_api_key" {
  type    = string
  default = ""
  description = "IBM Cloud API Key"
}

variable "cloud_provider" {
  type    = string
  default = "ibmcloud"
}

variable "is_private_repo" {
  type        = bool
  description = "Set to true if the source Git repository is private and requires an SSH key."
  default     = false
}

variable "ce_ssh_secret" {
  type    = string
}

variable "app_env_vars" {
  type        = map(string)
  description = "A map of environment variables to be injected into the application container."
  default     = {}
}

variable "ce_project_id" {
  description = "ID (GUID) of your existing Code Engine project"
  type        = string
}

variable "create_duration" {
  description = "The time alloted for image build"
  type        = string
  default     = "10m"
}

variable "strategy_size" {
  description = "The size alloted for image build"
  type        = string
  default     = "medium"
}

variable "ce_app_memory" {
  type        = string
  description = "The amount of memory (RAM) for each application instance (e.g., '2G')."
}

variable "ce_app_cpu" {
  type        = string
  description = "The number of vCPU for each application instance (e.g., '1')."
}