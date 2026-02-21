# Spacelift Core Orchestrator (m-orch)

The **Core Orchestrator Engine** for managing Spacelift Module Registry automation. This module provides a manifest-driven approach to registering VCS-integrated modules.

## Features
- **Dynamic Module Registration:** Automatically create `spacelift_module` resources from JSON manifests.
- **Layered Configuration:** Supports global defaults and enforced platform overrides.
- **VCS Hook Automation:** Provisions `azuredevops_servicehook_webhook_tfs` for all modules automatically.
- **Safety Checks:** Collision detection prevents multiple manifests from managing the same repository.

## Usage
Add this module to your space-specific repository and point it to your manifests directory.

```hcl
module "orchestrator" {
  source = "terraform-spacelift-m-orch"

  manifest_dir          = "./manifests"
  defaults_file         = "./config/_defaults.json"
  overrides_file        = "./config/_overrides.json"
  vcs_root_int_pw       = var.vcs_password
  spacelift_webhook_url = var.webhook_url
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | ~> 1.0 |
| <a name="requirement_spacelift"></a> [spacelift](#requirement\_spacelift) | ~> 1.44 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | ~> 1.0 |
| <a name="provider_spacelift"></a> [spacelift](#provider\_spacelift) | ~> 1.44 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_servicehook_webhook_tfs.webhooks](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/servicehook_webhook_tfs) | resource |
| [spacelift_context_attachment.attachment](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/context_attachment) | resource |
| [spacelift_module.this](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/module) | resource |
| [spacelift_module_test_case.test](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/module_test_case) | resource |
| [spacelift_policy_attachment.policy](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/policy_attachment) | resource |
| [azuredevops_git_repository.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/git_repository) | data source |
| [azuredevops_project.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) | data source |
| [spacelift_context.this](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/data-sources/context) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_context_name"></a> [admin\_context\_name](#input\_admin\_context\_name) | The context ID (slug) of the primary context to attach to all modules. | `string` | n/a | yes |
| <a name="input_default_ado_project"></a> [default\_ado\_project](#input\_default\_ado\_project) | The default Azure DevOps project name for repository lookups. | `string` | `"CLZ Technology and Automation"` | no |
| <a name="input_default_space_id"></a> [default\_space\_id](#input\_default\_space\_id) | The Spacelift Space where modules will be created if not overridden. | `string` | `"caf-01KH4MY9VEV4T70TD35V2D1KMP"` | no |
| <a name="input_defaults_file"></a> [defaults\_file](#input\_defaults\_file) | Path to the \_defaults.json file. | `string` | n/a | yes |
| <a name="input_manifest_dir"></a> [manifest\_dir](#input\_manifest\_dir) | Path to the directory containing module JSON manifests. | `string` | n/a | yes |
| <a name="input_overrides_file"></a> [overrides\_file](#input\_overrides\_file) | Path to the \_overrides.json file. | `string` | n/a | yes |
| <a name="input_space_map"></a> [space\_map](#input\_space\_map) | A mapping of logical bucket names to physical Spacelift Space IDs. | `map(string)` | <pre>{<br/>  "admin": "admin-01KH4MY9WKZMGCZ821VM92QVS9",<br/>  "azure": "azure-01KH4MY9VYX409F3SN26QRH4MQ",<br/>  "caf": "caf-01KH4MY9VEV4T70TD35V2D1KMP",<br/>  "dev-module": "dev-module-01KH4MY9XQ4V8Q09DHMZADHXYV",<br/>  "mcc": "mcc-01KH4MY9X7EEH51M14YX89A99T",<br/>  "privatecloud": "privatecloud-01KH4MY9Y9R2CZWGFM7FWAN9YD"<br/>}</pre> | no |
| <a name="input_spacelift_webhook_url"></a> [spacelift\_webhook\_url](#input\_spacelift\_webhook\_url) | The endpoint URL provided by Spacelift for the ADO integration. | `string` | n/a | yes |
| <a name="input_vcs_integration_id"></a> [vcs\_integration\_id](#input\_vcs\_integration\_id) | The ID of the Azure DevOps integration in Spacelift. | `string` | `"azuredevops_mclm"` | no |
| <a name="input_vcs_root_int_pw"></a> [vcs\_root\_int\_pw](#input\_vcs\_root\_int\_pw) | The basic auth password for the ADO webhook subscription. | `string` | n/a | yes |
| <a name="input_webhook_events"></a> [webhook\_events](#input\_webhook\_events) | A map of event names to ADO event types that trigger Spacelift. | <pre>map(object({<br/>    event_type : string<br/>  }))</pre> | <pre>{<br/>  "gitpush": {<br/>    "event_type": "git_push"<br/>  },<br/>  "pr_commented": {<br/>    "event_type": "git_pull_request_commented"<br/>  },<br/>  "pr_created": {<br/>    "event_type": "git_pull_request_created"<br/>  },<br/>  "pr_merge_attempted": {<br/>    "event_type": "git_pull_request_merge_attempted"<br/>  },<br/>  "pr_updated": {<br/>    "event_type": "git_pull_request_updated"<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_ids"></a> [module\_ids](#output\_module\_ids) | A map of the generated Spacelift module IDs. |
| <a name="output_module_spaces"></a> [module\_spaces](#output\_module\_spaces) | A map showing which Space each module was created in. |
| <a name="output_rejected_manifests"></a> [rejected\_manifests](#output\_rejected\_manifests) | Manifests skipped due to validation errors or repository collisions. |
| <a name="output_webhook_subscriptions"></a> [webhook\_subscriptions](#output\_webhook\_subscriptions) | Count of webhooks created across all repositories. |
<!-- END_TF_DOCS -->

## Spacelift Notes
- **Contexts:** This module attaches an "Admin Context" by default.
- **Worker Pools:** Can be overridden via the `worker_pool_id` field in individual manifests.

## Limitations
- **Namespace:** Only supports Azure DevOps as a VCS provider in its current form.
- **Repository Naming:** Strictly enforces the `terraform-<provider>-<name>` convention for managed modules.

## Contributing
Please follow the MCIAC Standards for all changes. Use the `develop` branch for active feature development.
