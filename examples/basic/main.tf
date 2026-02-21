# Example usage of the Spacelift Module Orchestrator
module "m-orch" {
  source = "../../"

  manifest_dir          = "${path.module}/manifests"
  defaults_file         = "${path.module}/config/_defaults.json"
  overrides_file        = "${path.module}/config/_overrides.json"
  
  # Auth credentials (should be provided via variables/env)
  vcs_root_int_pw       = "fake-password"
  spacelift_webhook_url = "https://spacelift.io/hooks/fake-id"
  admin_context_name    = "admin-context"
}
