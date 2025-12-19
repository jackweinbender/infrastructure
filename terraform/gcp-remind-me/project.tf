data "google_client_config" "current" {}

data "google_project" "current" {
  project_id = data.google_client_config.current.project
}
