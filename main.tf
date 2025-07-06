# Enable required Google Cloud APIs (only if Load Balancer is enabled)
resource "google_project_service" "compute_api" {
  count = var.enable_load_balancer ? 1 : 0

  project = var.project_id
  service = "compute.googleapis.com"

  # Enables Compute API if needed for Load Balancer;
  # Stays enabled on destroy to avoid disrupting other resources
  disable_on_destroy = false
}

resource "google_project_service" "storage_api" {
  project = var.project_id
  service = "storage.googleapis.com"

  # Enables Storage API if not already;
  # Stays enabled on destroy to avoid affecting other usage
  disable_on_destroy = false
}

# GCS Bucket for static website hosting
resource "google_storage_bucket" "website_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = var.force_destroy

  # Website configuration
  website {
    main_page_suffix = var.index_document
    not_found_page   = var.error_document
  }

  # Public access prevention - disable to allow website access
  public_access_prevention = "inherited"

  # Website configuration requires specific settings
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  # Versioning (optional)
  versioning {
    enabled = var.enable_versioning
  }

  # Uniform bucket-level access
  uniform_bucket_level_access = true

  # Labels for better organization
  labels = {
    name        = lower(replace(var.website_name, " ", "-"))
    environment = "production"
    managed_by  = "terraform"
    setup_type  = var.enable_load_balancer ? "load-balancer" : "direct-gcs"
  }

  depends_on = [
    google_project_service.storage_api
  ]
}

# Public read access for the bucket
resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
}

# Upload index.html
resource "google_storage_bucket_object" "index_html" {
  name   = var.index_document
  bucket = google_storage_bucket.website_bucket.name
  source = "${path.module}/static/${var.index_document}"

  # Cache control for better performance
  cache_control = "public, max-age=3600"
}

# Upload 404.html
resource "google_storage_bucket_object" "error_html" {
  name   = var.error_document
  bucket = google_storage_bucket.website_bucket.name
  source = "${path.module}/static/${var.error_document}"

  # Cache control for better performance
  cache_control = "public, max-age=3600"
}

# Upload CSS file
resource "google_storage_bucket_object" "styles_css" {
  name   = "styles.css"
  bucket = google_storage_bucket.website_bucket.name
  source = "${path.module}/static/styles.css"

  # Cache control for better performance
  cache_control = "public, max-age=86400"
}

# Load Balancer resources (only created if enabled)
resource "google_compute_backend_bucket" "website_backend" {
  count = var.enable_load_balancer ? 1 : 0

  name        = lower(replace(var.website_name, " ", "-"))
  description = "Backend bucket for static website hosting"
  bucket_name = google_storage_bucket.website_bucket.name

  # Enable Cloud CDN for better performance
  enable_cdn = true

  # CDN cache configuration
  cdn_policy {
    cache_mode       = "CACHE_ALL_STATIC"
    client_ttl       = 3600
    default_ttl      = 3600
    max_ttl          = 86400
    negative_caching = true
    negative_caching_policy {
      code = 404
      ttl  = 60
    }
  }

  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_compute_global_address" "website_ip" {
  count = var.enable_load_balancer ? 1 : 0

  name         = lower(replace(var.website_name, " ", "-"))
  description  = "Static IP address for website load balancer"
  address_type = "EXTERNAL"

  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_compute_url_map" "website_urlmap" {
  count = var.enable_load_balancer ? 1 : 0

  name            = lower(replace(var.website_name, " ", "-"))
  description     = "URL map for static website"
  default_service = google_compute_backend_bucket.website_backend[0].self_link

  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_compute_target_http_proxy" "website_http_proxy" {
  count = var.enable_load_balancer ? 1 : 0

  name    = lower(replace(var.website_name, " ", "-"))
  url_map = google_compute_url_map.website_urlmap[0].self_link

  depends_on = [
    google_project_service.compute_api
  ]
}

resource "google_compute_global_forwarding_rule" "website_http" {
  count = var.enable_load_balancer ? 1 : 0

  name       = lower(replace(var.website_name, " ", "-"))
  target     = google_compute_target_http_proxy.website_http_proxy[0].self_link
  port_range = "80"
  ip_address = google_compute_global_address.website_ip[0].address

  depends_on = [
    google_project_service.compute_api
  ]
}
