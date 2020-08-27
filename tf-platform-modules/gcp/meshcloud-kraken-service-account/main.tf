variable sa_name {
  type = string
}

variable project_id {
  type = string
}

resource google_service_account meshcloud_kraken_sa {
  account_id   = var.sa_name
  display_name = "meshcloud kraken service account"
  description  = "This SA is used by meshcloud to obtain billing and related information for the kraken module"
  project      = var.project_id
}

resource google_project_iam_member bigquery_jobuser {
  project = var.project_id
  role    = "roles/bigquery.jobUser"

  member = "serviceAccount:${google_service_account.meshcloud_kraken_sa.email}"
}

resource google_project_iam_member biquery_dataViewer {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"

  member = "serviceAccount:${google_service_account.meshcloud_kraken_sa.email}"
}

# You can obtain the json representation of the sa key to put it into vault
# from the terraform state. Simply base64 decode what's in the private_key field
resource google_service_account_key sa_key {
  service_account_id = google_service_account.meshcloud_kraken_sa.id
}

output sa_key {
  value       = google_service_account_key.sa_key.private_key
  description = "Service Account Key (base64 encoded credential.json)"
}