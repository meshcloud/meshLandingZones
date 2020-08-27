provider google {
  project = "meshstack-infra"
  version = "=3.7"
}

terraform {
  backend gcs {
    bucket = "meshcloud-tf-states"
    prefix = "meshstack-infra/meshcloud-tf-states-bucket"
  }
}

resource google_storage_bucket tf_states {
  name               = "meshcloud-tf-states"
  location           = "europe-west3"
  storage_class      = "REGIONAL"
  bucket_policy_only = true
}

resource google_storage_bucket_iam_member storage_admins {
  bucket = google_storage_bucket.tf_states.name
  role   = "roles/storage.admin"
  member = "projectOwner:meshstack-infra"
}

resource google_storage_bucket_iam_member storage_admins_2 {
  bucket = google_storage_bucket.tf_states.name
  role   = "roles/storage.admin"
  member = "projectEditor:meshstack-infra"
}
