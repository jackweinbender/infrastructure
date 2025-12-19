resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "github-actions-pool"
}

resource "google_iam_workload_identity_pool_provider" "example" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-jackweinbender"
  display_name                       = "gh-jackweinbender"
  description                        = "GitHub Actions identity pool provider for automated test"
  attribute_condition                = "assertion.repository_owner == 'jackweinbender'"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.aud"              = "assertion.aud"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

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

data "google_client_config" "current" {}

output "workload_identity_provider" {
  description = "Full resource name of the workload identity provider for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.example.name
}

output "service_account_email" {
  description = "Email of the GitHub Actions service account"
  value       = google_service_account.github_actions.email
}
