terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Artifact Registry
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "aspnet-repo"
  format        = "DOCKER"

  lifecycle {
    prevent_destroy = true
  }
}

# Cloud Run Service Account
resource "google_service_account" "cloudrun_sa" {
  account_id   = "cloudrun-sa"
  display_name = "Cloud Run Service Account"

  lifecycle {
    prevent_destroy = true
  }
}

# Allow Cloud Run to pull images
resource "google_project_iam_member" "artifact_access" {
  project = var.project_id
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}


# This example uses the google_cloud_run_v2_service resource.
resource "google_cloud_run_v2_service" "default" {
  name     = "shoppingdemo-app-v2" # The name of the service
  location = "us-central1"           # The location (region) of the service
  ingress = "INGRESS_TRAFFIC_ALL"

  # Configuration for the service template (defines the deployed container)
  template {
    # The container configuration
    containers {
      image = var.image # The container image URL
      ports {
        container_port = 8080
      }

      # Optional: Define resource limits
      resources {
        cpu_idle = true # Allows CPU to be idled when not processing requests
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
    # Optional: Configure scaling parameters directly (v2 API approach)
    scaling {
      max_instance_count = 10 # Maximum number of container instances
      min_instance_count = 0  # Minimum number of container instances
    }
  }

  # Makes the service publicly accessible (IAM setting handled separately for security best practice)
  # For immediate public access, the 'allUsers' principal needs the 'roles/run.invoker' role.
}

# Granting public access to the service
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
