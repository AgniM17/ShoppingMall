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
    # Don't try to recreate if it already exists
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

# Cloud Run Service
resource "google_cloud_run_service" "app" {
  name     = "shoppingdemo-app"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloudrun_sa.email

      containers {
        image = "us-docker.pkg.dev/${var.project_id}/aspnet-repo/app:latest"
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Public access
resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.app.name
  location = google_cloud_run_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
