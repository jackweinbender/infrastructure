resource "google_artifact_registry_repository" "docker_releases" {
  location      = "us"
  repository_id = "releases"
  description   = "Docker container registry for production builds"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "docker_nonprod" {
  location      = "us"
  repository_id = "nonprod"
  description   = "Docker container registry for normal builds"
  format        = "DOCKER"
}

# ServiceAccounts for Cloud Run to pull from Artifact Registry
data "google_service_account" "remindme_cloudrun_robot" {
  account_id = "remind-me-481700"
  name       = "service-13264350760@serverless-robot-prod.iam.gserviceaccount.com"
}
locals {
  pull_sa_members = [
    data.google_service_account.remindme_cloudrun_robot.member
  ]
}
resource "google_artifact_registry_repository_iam_member" "cloudrun_reader_releases" {
  for_each   = toset(local.pull_sa_members)
  location   = google_artifact_registry_repository.docker_releases.location
  repository = google_artifact_registry_repository.docker_releases.repository_id
  role       = "roles/artifactregistry.reader"
  member     = each.value
}
resource "google_artifact_registry_repository_iam_member" "cloudrun_reader_nonprod" {
  for_each   = toset(local.pull_sa_members)
  location   = google_artifact_registry_repository.docker_nonprod.location
  repository = google_artifact_registry_repository.docker_nonprod.repository_id
  role       = "roles/artifactregistry.reader"
  member     = each.value
}
