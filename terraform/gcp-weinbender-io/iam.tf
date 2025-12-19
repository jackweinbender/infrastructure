resource "google_service_account" "github_actions" {
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository_owner/jackweinbender"
}

resource "google_project_iam_member" "terraform_editor" {
  project = data.google_client_config.current.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}
