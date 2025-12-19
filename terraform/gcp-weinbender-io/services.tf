locals {
  enabled_apis = [
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ]
}

resource "google_project_service" "project" {
  for_each = toset(local.enabled_apis)
  service  = each.value
}
