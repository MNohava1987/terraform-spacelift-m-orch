locals {
  # Load manifests
  raw_manifests = {
    for f in fileset(var.manifest_dir, "*.json") :
    trimsuffix(f, ".json") => jsondecode(file("${var.manifest_dir}/${f}"))
  }

  # Load global layers
  global_defaults  = jsondecode(file(var.defaults_file))
  global_overrides = jsondecode(file(var.overrides_file))

  # Normalization
  normalized_manifests = {
    for filename, config in local.raw_manifests : filename => merge(
      { name = filename },
      config,
      {
        vcs = {
          namespace = coalesce(try(config.vcs.namespace, null), try(local.global_defaults.vcs.namespace, null), var.default_ado_project)
        }
      }
    )
  }

  # Repository collision detection
  manifest_repo_pairs = [for f, c in local.normalized_manifests : "${c.vcs.namespace}/${c.repository}" if can(c.repository)]
  duplicate_repos     = [for pair in distinct(local.manifest_repo_pairs) : pair if length([for p in local.manifest_repo_pairs : p if p == pair]) > 1]

  # Gatekeeper
  valid_manifests = {
    for f, c in local.normalized_manifests : c.name => c
    if can(c.name) && can(c.repository) && !contains(local.duplicate_repos, "${c.vcs.namespace}/${c.repository}")
  }

    # Audit
    rejected_manifests = {
      for f, c in local.normalized_manifests : f => compact([
        !can(c.repository) ? "Missing required field: 'repository'" : null,
        contains(local.duplicate_repos, try("${c.vcs.namespace}/${c.repository}", "")) ? "Repository collision." : null,
        can(c.labels) && length([for l in try(c.labels, []) : l if can(regex("^[a-z0-9:._-]+$", l))]) != length(try(c.labels, [])) ? "Label formatting error." : null,
        # Fix 5: Module name validation
        !can(regex("^[a-z0-9-]+$", c.name)) ? "Invalid module name: must be lowercase alphanumeric and hyphens." : null,
        # Fix 6: Space ID validation (Allow keys from space_map OR physical ID format)
        !can(regex("^(root|[a-z0-9-]{30})$", try(c.space_id, local.global_defaults.space_id, local.global_overrides.space_id, "root"))) && !contains(keys(var.space_map), try(c.space_id, local.global_defaults.space_id, local.global_overrides.space_id, "root")) ? "Invalid Space ID or logical name." : null
      ])
      if !can(c.repository) || 
         contains(local.duplicate_repos, try("${c.vcs.namespace}/${c.repository}", "")) || 
         (can(c.labels) && length([for l in try(c.labels, []) : l if can(regex("^[a-z0-9:._-]+$", l))]) != length(try(c.labels, []))) ||
         !can(regex("^[a-z0-9-]+$", c.name)) ||
         (!can(regex("^(root|[a-z0-9-]{30})$", try(c.space_id, local.global_defaults.space_id, local.global_overrides.space_id, "root"))) && !contains(keys(var.space_map), try(c.space_id, local.global_defaults.space_id, local.global_overrides.space_id, "root")))
    }
  
    # Final processed module configs
    module_configs = {
      for name, config in local.valid_manifests : name => merge(
        local.global_defaults,
        config,
        local.global_overrides,
        {
          # Resolve space_id from map if a logical name is provided
          space_id = lookup(var.space_map, 
            try(config.space_id, local.global_defaults.space_id, local.global_overrides.space_id, var.default_space_id), 
            try(config.space_id, local.global_defaults.space_id, local.global_overrides.space_id, var.default_space_id)
          )
          labels = distinct(concat(
            try(local.global_defaults.labels, []),
            try(config.labels, []),
            try(local.global_overrides.labels, []),
            try(["owner:${config.owner}"], [])
          ))
        }
      )
      if !startswith(name, "_")
    }
    # Build map for native Spacelift Test Cases
  module_test_cases = flatten([
    for module_name, config in local.module_configs : [
      for test_name, test_config in merge(
        { "unit-test" = {} },
        try(config.additional_test_cases, {})
      ) : {
        module_name   = module_name
        test_name     = test_name
        workflow_tool = try(test_config.workflow_tool, "TERRAFORM_FOSS")
        key           = "${module_name}-${test_name}"
      }
      if try(config.enable_test_cases, true)
    ]
  ])
  module_test_cases_map = { for item in local.module_test_cases : item.key => item }

  # Build map for context attachments
  module_contexts = flatten([
    for module_name, config in local.module_configs : [
      for ctx_id in distinct(concat([var.admin_context_name], try(config.additional_contexts, []))) : {
        module_name = module_name
        context_id  = ctx_id
        key         = "${module_name}-${ctx_id}"
      }
    ]
  ])
  module_contexts_map = { for item in local.module_contexts : item.key => item }

  # Build map for policy attachments
  module_policies = flatten([
    for module_name, config in local.module_configs : [
      for policy_id in try(config.policies, []) : {
        module_name = module_name
        policy_id   = policy_id
        key         = "${module_name}-${policy_id}"
      }
    ]
  ])
  module_policies_map = { for item in local.module_policies : item.key => item }

  # Flatten for ADO webhooks
  module_webhooks = flatten([
    for module_name, config in local.module_configs : [
      for event_name, event_config in merge(var.webhook_events, try(config.additional_webhooks, {})) : {
        module_name = module_name
        event_name  = event_name
        event_type  = event_config.event_type
        repo_name   = config.repository
        ado_project = config.vcs.namespace
        branch      = try(config.branch, "main")
        key         = "${module_name}-${event_name}"
      }
      if !contains(try(config.disabled_webhooks, []), event_name)
    ]
    if try(config.enable_webhooks, true)
  ])
  module_webhooks_map = { for item in local.module_webhooks : item.key => item }
}