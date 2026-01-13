output "cloud_run_url" {
  value = google_cloud_run_v2_service.default.status[0].url
}
