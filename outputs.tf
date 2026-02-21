output "module_ids" {
  description = "A map of the generated Spacelift module IDs."
  value       = { for k, v in spacelift_module.this : k => v.id }
}

output "module_spaces" {
  description = "A map showing which Space each module was created in."
  value       = { for k, v in spacelift_module.this : k => v.space_id }
}

output "webhook_subscriptions" {
  description = "Count of webhooks created across all repositories."
  value       = length(azuredevops_servicehook_webhook_tfs.webhooks)
}

# Notification for rejected manifests
output "rejected_manifests" {
  description = "Manifests skipped due to validation errors or repository collisions."
  value       = local.rejected_manifests
}
