# Dynamic lookups for existing Spacelift resources.

# Temporarily disabled during bootstrap phase.
/*
data "spacelift_context" "this" {
  for_each   = toset(local.module_contexts_list)
  context_id = each.value
}
*/
