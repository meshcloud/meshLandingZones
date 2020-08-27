provider google {
  version = "3.34.0"
}

terraform {
  backend gcs {
    prefix = "meshcloud-dev/gcp"
    bucket = "meshcloud-tf-states"
  }
}

locals {
  org_id             = "12345678"
  billing_account_id = "XXXXX-12345"
}

# GCP Project

resource google_project meshstack_root {
  name            = "meshstack-root"
  project_id      = "meshstack-root"
  org_id          = local.org_id
  billing_account = local.billing_account_id
}

# Kraken
module new_kraken_sa {
  source = "../tf-platform-modules/gcp/meshcloud-kraken-service-account/"

  sa_name    = "mesh-kraken-service"
  project_id = "meshstack-root"
}

output "kraken_sa_key" {
  value = module.new_kraken_sa.sa_key
}

# Replicator

module new_replicator_sa {
  source = "../tf-platform-modules/gcp/meshcloud-replicator-service-account/"

  sa_name    = "mesh-replicator-service"
  project_id = "meshstack-root"
  org_id     = local.org_id

  landing_zone_folder_ids = [
    "12345", 
    "6789" 
  ]

  billing_account_id = local.billing_account_id
}

output "replicator_sa_key" {
  value = module.new_replicator_sa.sa_key
}

output replicator_manual_setup {
  value = module.new_replicator_sa.replicator_manual_setup
}

## Landing Zone GDM Templates

### Note: Setting up the GDM Bucket and the templates inside it is not part of this example yet

### Give replicator access to gcm templates
module cloudfoundation_gdm_access {
  source = "../tf-platform-modules/gcp/meshcloud-replicator-lz-access-gdm-template/"
  project_id  = "cloudfoundation"
  bucket_name = "cloudfoundation-gdm-templates"
  sa_email    = module.new_replicator_sa.sa_email
}

## Landing Zone Cloud Functions

## Create cloud founction example "ReturnHeader"
module cloudfunction_ReturnHeader {
  source  = "./cf-return-header"
  project = google_project.meshstack_root.project_id
}

## Grant permisson to invoke clound function ReturnHeader
module cloudfunction_ReturnHeader_invoke_permisson {
  source = "../tf-platform-modules/gcp/meshcloud-replicator-lz-access-cloudfunction"

  sa_email       = module.new_replicator_sa.sa_email
  cloud_function = module.cloudfunction_ReturnHeader.cloud_function
  region         = module.cloudfunction_ReturnHeader.region
  project_id     = module.cloudfunction_ReturnHeader.project
}