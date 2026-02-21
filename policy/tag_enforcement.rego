package spacelift.plan

# MCIAC Standard: Resource Tagging
# This policy ensures that all resources created by this module
# include the mandatory organizational labels/tags.

mandatory_labels := {"managed-by", "env", "org"}

deny[msg] {
    resource := input.terraform.resource_changes[_]
    resource.mode == "managed"

    # Check for labels (GCP) or tags (AWS/Azure)
    labels := object.get(resource.change.after, "labels", object.get(resource.change.after, "tags", {}))

    missing := mandatory_labels - {label | labels[label]}
    count(missing) > 0

    msg := sprintf("Resource '%v' is missing mandatory labels: %v", [resource.address, missing])
}
