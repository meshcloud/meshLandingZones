variable sa_email {
  type        = string
  description = "email of the meshcloud replicator ServiceAccount to grant access to the Bucket where the GDM Templates are stored"
}

variable project_id {
  type        = string
  description = "GCP Project Id where the bucket is located"
}

variable bucket_name {
  type        = string
  description = "The bucket name in the project where the GDM Templates are stored"
}

# note: this role could also possibly be defined on the infrastructure project holding the GDM Template Buckets instead
# of the organization level. However in meshcloud-dev we have multiple infrastructure projects (likvid & meshcloud-dev).

resource google_project_iam_custom_role replicator_service {
  role_id     = "meshcloud_replicator_gdm_bucket_access"
  project     = var.project_id
  title       = "meshcloud replicator GDM template bucket access"
  description = "Role for the meshcloud replicator ServiceAccount to access GDM Templates referenced in Landing Zones. See https://docs.meshcloud.io/docs/meshstack.gcp.landing-zones.html"
  permissions = [
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.list",
    "storage.buckets.setIamPolicy",
    "storage.objects.get",
    "storage.objects.list",
  ]
}


resource google_storage_bucket_iam_member google_deployment_manager_service_account {
  bucket = var.bucket_name
  role   = google_project_iam_custom_role.replicator_service.id
  member = "serviceAccount:${var.sa_email}"
}