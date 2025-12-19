resource "google_cloud_run_v2_service" "remindme" {
  name                = "remind-me"
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

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_v2_service.remindme.name
  location = google_cloud_run_v2_service.remindme.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
