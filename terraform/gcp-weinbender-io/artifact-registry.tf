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
