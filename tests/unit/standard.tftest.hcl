# Native Terraform Test File (MCIAC 11.1)
# Validates orchestrator configuration merge and normalization logic

variables {
  manifest_dir          = "manifests"
  defaults_file         = "config/_defaults.json"
  overrides_file        = "config/_overrides.json"
  vcs_root_int_pw       = "test-password"
  spacelift_webhook_url = "https://example.com/webhook"
  admin_context_name    = "admin-ctx"
}

run "validate_orchestrator_initialization" {
  command = plan
  # This ensures the plan can be generated without errors in the logic
}
