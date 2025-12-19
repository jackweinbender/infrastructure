# Production Environment
resource "google_cloud_run_v2_service" "remindme_prod" {
  name                = "remindme-prod"
  location            = "us-central1"
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"
  scaling {
    max_instance_count = 1
  }
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}
# Allow public (unauthenticated) access to the production Cloud Run service
resource "google_cloud_run_service_iam_member" "public_access_prod" {
  service  = google_cloud_run_v2_service.remindme_prod.name
  location = google_cloud_run_v2_service.remindme_prod.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
