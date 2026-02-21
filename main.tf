# Dynamically create Spacelift modules based on the merged configuration layers.
resource "spacelift_module" "this" {
  for_each = local.module_configs

  # Use the stable 'name' from the manifest as the identity
  name               = each.value.name
  terraform_provider = try(each.value.terraform_provider, "google")
  description        = try(each.value.description, "Managed Spacelift Module: ${each.value.name}")
  space_id           = try(each.value.space_id, var.default_space_id)
  repository         = each.value.repository
  branch             = try(each.value.branch, "main")
  project_root       = try(each.value.project_root, null)
  space_shares       = try(each.value.space_shares, [])
  workflow_tool      = try(each.value.workflow_tool, "TERRAFORM_FOSS")

  # Administrative flags and worker pools
  administrative        = try(each.value.administrative, false)
  worker_pool_id        = try(each.value.worker_pool_id, null)
  protect_from_deletion = try(each.value.protect_from_deletion, true)

  # --- Dynamic VCS Configuration ---
  
  # Standard GitHub App Integration
  dynamic "github_enterprise" {
    for_each = var.vcs_provider == "GITHUB" ? [1] : []
    content {
      namespace = each.value.vcs.namespace
      id        = var.vcs_integration_id
    }
  }

  # Azure DevOps Integration
  dynamic "azure_devops" {
    for_each = var.vcs_provider == "AZURE_DEVOPS" ? [1] : []
    content {
      project = each.value.vcs.namespace
      id      = var.vcs_integration_id
    }
  }

  labels = try(each.value.labels, [])
}

# Attach modules to their requested Spacelift contexts.
resource "spacelift_context_attachment" "attachment" {
  for_each = local.module_contexts_map

  context_id = data.spacelift_context.this[each.value.context_id].id
  module_id  = spacelift_module.this[each.value.module_name].id
}

# Attach modules to specific Spacelift policies.
resource "spacelift_policy_attachment" "policy" {
  for_each = local.module_policies_map

  policy_id = each.value.policy_id
  module_id = spacelift_module.this[each.value.module_name].id
}

# Native Spacelift Module Test Cases
resource "spacelift_test_case" "test" {
  for_each = local.module_test_cases_map

  name          = each.value.test_name
  module_id     = spacelift_module.this[each.value.module_name].id
  workflow_tool = each.value.workflow_tool
}

# Webhooks are typically only needed for ADO or legacy integrations.
# Standard GitHub App integration handles events natively.
resource "azuredevops_servicehook_webhook_tfs" "webhooks" {
  for_each = var.vcs_provider == "AZURE_DEVOPS" ? local.module_webhooks_map : {}

  project_id          = data.azuredevops_project.this[each.value.ado_project].id
  url                 = var.spacelift_webhook_url
  basic_auth_password = var.vcs_root_int_pw

  dynamic "git_push" {
    for_each = each.value.event_type == "git_push" ? [1] : []
    content {
      branch        = "refs/heads/${each.value.branch}"
      repository_id = data.azuredevops_git_repository.this[each.value.module_name].id
    }
  }
  # ... (other events truncated for brevity, but logic remains same)
}
