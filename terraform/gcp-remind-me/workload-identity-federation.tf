data "google_client_config" "current" {}

resource "google_project_iam_member" "terraform_editor" {
  project = data.google_client_config.current.project
  role    = "roles/editor"
  member  = "serviceAccount:github-actions@weinbender-io.iam.gserviceaccount.com"
}
