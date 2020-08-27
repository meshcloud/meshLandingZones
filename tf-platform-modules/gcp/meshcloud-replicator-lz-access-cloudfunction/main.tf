variable sa_email {
  type        = string
  description = "email of the meshcloud replicator ServiceAccount to invoke the cloud function"
}

variable cloud_function {
  type        = string
  description = "The cloud function name that the replicator ServiceAccount invokes"
}

variable project_id {
  type        = string
  description = "GCP Project Id where the cloud function is located"
}

variable region {
  type        = string
  description = "The location of this cloud function"
}

## Grant Access to LZ Functions
resource google_cloudfunctions_function_iam_member invoker {
  cloud_function = var.cloud_function
  project        = var.project_id
  region         = var.region
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.sa_email}"
}
