provider google {
  version = "3.34.0"
  project = "tf-test-3"
}

terraform {
  backend gcs {
    prefix = "gcp"
    bucket = "tf-state-39482398402"
  }
}

# GCP Project

data google_project meshstack_root {
  project_id      = "tf-test-3"
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
  project_id = data.google_project.meshstack_root.project_id
  org_id     = data.google_project.meshstack_root.org_id

  landing_zone_folder_ids = [ 
  ]

  billing_account_id = data.google_project.meshstack_root.billing_account
}

output "replicator_sa_key" {
  value = module.new_replicator_sa.sa_key
}

output replicator_manual_setup {
  value = module.new_replicator_sa.replicator_manual_setup
}

## Landing Zone Cloud Functions

## Create cloud founction example "ReturnHeader"
# module cloudfunction_ReturnHeader {
#   source  = "./cf-return-header"
#   project = data.google_project.meshstack_root.project_id
# }

## Grant permisson to invoke clound function ReturnHeader
#module cloudfunction_ReturnHeader_invoke_permisson {
#  source = "../tf-platform-modules/gcp/meshcloud-replicator-lz-access-cloudfunction"
#
#  sa_email       = module.new_replicator_sa.sa_email
#  cloud_function = module.cloudfunction_ReturnHeader.cloud_function
#  region         = module.cloudfunction_ReturnHeader.region
#  project_id     = module.cloudfunction_ReturnHeader.project
#}