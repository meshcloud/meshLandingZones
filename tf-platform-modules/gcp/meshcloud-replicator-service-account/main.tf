variable sa_name {
  type        = string
  description = "name of the ServiceAccount to create"
}

variable org_id {
  type        = string
  description = "GCP Organization Id"
}

variable project_id {
  type        = string
  description = "GCP Project ID where to create the resources. This is typically a 'meshstack-root' project"
}

variable landing_zone_folder_ids {
  type        = set(string)
  description = "GCP Folders that make up the Landing Zone. The service account will only receive permissions on these folders."
}

variable billing_account_id {
  type        = string
  description = "The GCP Billing Account in your organization."
}

resource google_service_account replicator_service {
  account_id   = var.sa_name
  display_name = "meshcloud replicator service account"
  description  = "This SA is used by meshcloud to replicate the desired cloud state into GCP"
  project      = var.project_id
}

resource google_organization_iam_custom_role replicator_service {
  role_id     = "meshcloud_replicator_service"
  org_id      = var.org_id
  title       = "meshcloud replicator service role"
  description = "Role for the meshcloud replicator ServiceAccount used for project replication. See https://docs.meshcloud.io/docs/meshstack.gcp.index.html#replicator_service-iam-role"
  permissions = [
    "resourcemanager.folders.get",
    "resourcemanager.folders.list",
    "resourcemanager.organizations.get",
    "resourcemanager.projects.create",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.list",
    "resourcemanager.projects.move",
    "resourcemanager.projects.setIamPolicy",
    "resourcemanager.projects.update",
    "resourcemanager.projects.createBillingAssignment",
    "resourcemanager.projects.deleteBillingAssignment",

    "billing.resourceAssociations.create",

    "serviceusage.services.enable",
    "serviceusage.services.get",

    # these are required for GDM Integration
    "deploymentmanager.deployments.delete",
    "deploymentmanager.deployments.create",
    "deploymentmanager.deployments.update",
    "deploymentmanager.deployments.get",
  ]
}


# We apply a hardened security configuration, i.e. we assign permissions only on LZ folders instead of the organization
# root

resource google_folder_iam_member replicator_service {
  for_each = var.landing_zone_folder_ids

  folder = each.value
  role   = google_organization_iam_custom_role.replicator_service.id
  member = "serviceAccount:${google_service_account.replicator_service.email}"
}

# And we also have to assign the role on the Billing Account.

/*
  Billing Accounts are associated with an organization and can thus inherit organization level role assignments
  see https://cloud.google.com/billing/docs/how-to/billing-access).

  The replicator needs the "billing.resourceAssociations.create" permission "on the billing account", and since we 
  don't want to use an organization level role assignment, we have to assign it the permission directly on the billing
  account instead. It's not possible or sufficient to create the role assignment on a folder level because the
  Billing Account "lives in the Organization" but outside the folder/project hierahchy.
*/

resource google_billing_account_iam_member replicator_service {
  billing_account_id = var.billing_account_id
  role               = google_organization_iam_custom_role.replicator_service.id
  member             = "serviceAccount:${google_service_account.replicator_service.email}"
}

# You can obtain the json representation of the sa key to put it into vault
# from the terraform state. Simply base64 decode what's in the private_key field
resource google_service_account_key sa_key {
  service_account_id = google_service_account.replicator_service.id
}

output sa_key {
  value       = google_service_account_key.sa_key.private_key
  description = "Service Account Key (base64 encoded credential.json)"
}

output sa_email {
  value       = google_service_account.replicator_service.email
  description = "Service Account email"
}

# further manual setup is required due to https://github.com/hashicorp/terraform-provider-google/issues/1959
output replicator_manual_setup {
  value = <<EOF
  Attention. The created service account ${google_service_account.replicator_service.email} needs to be manually enabled for 'G Suite Domain-wide Delegation' and granted access to impersonate the meshfed-service user in Google Admin Console.
  See https://docs.meshcloud.io/docs/meshstack.gcp.index.html#enable-automated-oauth-consent for instructions.
  EOF
}