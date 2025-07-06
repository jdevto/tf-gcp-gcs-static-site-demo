variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "The name of the GCS bucket (must be globally unique)"
  type        = string
}

variable "website_name" {
  description = "The name of the website (used for labels and descriptions)"
  type        = string
  default     = "Static Website"
}

variable "enable_versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Force destroy the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "index_document" {
  description = "The name of the index document"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The name of the error document"
  type        = string
  default     = "404.html"
}

variable "enable_load_balancer" {
  description = "Enable Load Balancer for proper website behavior (serves index.html automatically and custom 404 pages)"
  type        = bool
  default     = false
}
