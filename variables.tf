variable "vcs_provider" {
  type        = string
  description = "The VCS provider to use (GITHUB or AZURE_DEVOPS)"
  default     = "GITHUB"
}

variable "vcs_integration_id" {
  type        = string
  description = "The ID of the VCS integration in Spacelift"
}

variable "manifest_dir" {
  type        = string
  description = "Path to the directory containing module JSON manifests"
}

variable "defaults_file" {
  type        = string
  description = "Path to the _defaults.json file"
}

variable "overrides_file" {
  type        = string
  description = "Path to the _overrides.json file"
}

variable "default_space_id" {
  type        = string
  description = "The Spacelift Space where modules will be created if not overridden"
}

variable "admin_context_name" {
  type        = string
  description = "The context ID (slug) of the primary context to attach to all modules"
}

# --- Legacy/Optional Variables (for backward compatibility) ---
variable "vcs_root_int_pw" {
  type      = string
  default   = ""
  sensitive = true
}

variable "spacelift_webhook_url" {
  type    = string
  default = ""
}

variable "default_ado_project" {
  type    = string
  default = ""
}

variable "webhook_events" {
  type    = any
  default = {}
}

variable "space_map" {
  type    = map(string)
  default = {}
}
