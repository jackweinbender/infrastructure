resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "github-actions-pool"
}

resource "google_iam_workload_identity_pool_provider" "example" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "gha-jackweinbender"
  display_name                       = "gha-jackweinbender"
  description                        = "GitHub Actions identity pool provider for jackweinbender GitHub account"
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
