locals {
  enabled_apis = [
    "run.googleapis.com"
  ]
}

resource "google_project_service" "project" {
  for_each = toset(local.enabled_apis)
  service  = each.value
}
