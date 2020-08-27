variable project {
  type = string
}

locals {
  func_name = "ReturnHeader"
  region    = "europe-west3"
}

# enable cloudbuild service, this is required for deploying the function
resource google_project_service project {
  project = var.project
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
}

# We use local-exec for two reasons here
# 1. We do not need a bucket if we deploy the function directly with the cli
# 2. We do no have to worry about zipping the content
resource null_resource deploy_function {

  triggers = {
    policy_sha1 = sha1(file("${path.module}/hellofunc.go"))
    func_name   = local.func_name
    project     = var.project
    region      = local.region
    src_path    = path.module
  }

  # confirmed to work with Google Cloud SDK 301.0.0
  provisioner local-exec {
    command = "gcloud functions deploy ${self.triggers.func_name} --runtime go113 --trigger-http --no-allow-unauthenticated --region ${self.triggers.region} --project ${self.triggers.project} --source ${self.triggers.src_path}"
  }

  provisioner local-exec {
    when    = destroy
    command = "gcloud functions delete ${self.triggers.func_name} --region ${self.triggers.region} --project ${self.triggers.project} --quiet"
  }
}

output cloud_function {
  value       = local.func_name
  description = "Cloud function name"
}

output project {
  value       = var.project
  description = "GCP Project Id where cloud function is located"
}

output region {
  value       = local.region
  description = "The location of this cloud function"
}