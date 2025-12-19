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

resource "google_artifact_registry_repository_iam_member" "cloudrun_reader_releases" {
  location   = google_artifact_registry_repository.docker_releases.location
  repository = google_artifact_registry_repository.docker_releases.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-13264350760@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_artifact_registry_repository_iam_member" "cloudrun_reader_nonprod" {
  location   = google_artifact_registry_repository.docker_nonprod.location
  repository = google_artifact_registry_repository.docker_nonprod.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-13264350760@serverless-robot-prod.iam.gserviceaccount.com"
}
