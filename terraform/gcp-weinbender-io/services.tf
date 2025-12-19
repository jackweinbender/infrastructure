locals {
  enabled_apis = [
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com"
  ]
}

resource "google_project_service" "project" {
  for_each = toset(local.enabled_apis)
  service  = each.value
}
