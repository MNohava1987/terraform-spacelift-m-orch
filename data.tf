# ADO project and repo lookups
data "azuredevops_project" "this" {
  for_each = toset([for c in local.module_configs : c.vcs.namespace])
  name     = each.key
}

data "azuredevops_git_repository" "this" {
  for_each   = local.module_configs
  project_id = data.azuredevops_project.this[each.value.vcs.namespace].id
  name       = each.value.repository
}

# Context lookups by context_id (slug) as required by provider v1.44.0
data "spacelift_context" "this" {
  for_each   = toset([for item in local.module_contexts : item.context_id])
  context_id = each.key
}
