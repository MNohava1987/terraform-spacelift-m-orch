# Dynamically create Spacelift modules based on the merged configuration layers.
resource "spacelift_module" "this" {
  for_each = local.module_configs

  name               = each.value.name
  terraform_provider = try(each.value.terraform_provider, "google")
  description        = try(each.value.description, "Managed Spacelift Module: ${each.value.name}")
  space_id           = try(each.value.space_id, var.default_space_id)
  repository         = each.value.repository
  branch             = try(each.value.branch, "main")
  project_root       = try(each.value.project_root, null)
  workflow_tool      = try(each.value.workflow_tool, "TERRAFORM_FOSS")

  administrative        = try(each.value.administrative, false)
  worker_pool_id        = try(each.value.worker_pool_id, null)
  protect_from_deletion = try(each.value.protect_from_deletion, true)

  # Standard GitHub App Integration (Inherited default)
  # We only use explicit blocks for non-default or Enterprise integrations.
  
  labels = try(each.value.labels, [])
}

# Attach modules to their requested Spacelift contexts.
# Temporarily commented out to avoid "context not found" errors during bootstrap.
/*
resource "spacelift_context_attachment" "attachment" {
  for_each = local.module_contexts_map

  context_id = data.spacelift_context.this[each.value.context_id].id
  module_id  = spacelift_module.this[each.value.module_name].id
}
*/

# Attach modules to specific Spacelift policies.
# Temporarily commented out to avoid attachment errors during bootstrap.
/*
resource "spacelift_policy_attachment" "policy" {
  for_each = local.module_policies_map

  policy_id = each.value.policy_id
  module_id = spacelift_module.this[each.value.module_name].id
}
*/
