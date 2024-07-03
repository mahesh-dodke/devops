variable "gcp_credentials_file" {
  description = "Path to the GCP credentials file"
  type        = string
  sensitive   = true
}

variable "google_credentials" {
  description = "JSON of the GCP credentials file"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "branch" {
  description = "Branch name"
  type        = string
}

variable "domain" {
  description = "Base domain"
  type        = string
}

variable "feature_branch" {
  description = "Feature branch name, if applicable"
  type        = string
  default     = ""
}

variable "commit_hash" {
  description = "Commit hash for feature branch"
  type        = string
  default     = ""
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
}

variable "dns_zone" {
  description = "DNS zone for managing records"
  type        = string
  sensitive   = true
}
