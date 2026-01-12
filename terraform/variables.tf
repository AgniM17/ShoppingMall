variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "image" {
  type        = string
  description = "Docker image for Cloud Run service"
  default = ""
}
