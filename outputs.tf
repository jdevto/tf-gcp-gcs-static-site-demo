output "bucket_name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.website_bucket.name
}

output "setup_type" {
  description = "The type of setup deployed"
  value       = var.enable_load_balancer ? "Load Balancer" : "Direct GCS"
}

output "website_url" {
  description = "The primary website URL"
  value = var.enable_load_balancer ? (
    "http://${google_compute_global_address.website_ip[0].address}/"
    ) : (
    "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/index.html"
  )
}

output "website_endpoint_info" {
  description = "Website endpoint information and behavior"
  value = var.enable_load_balancer ? {
    type        = "Load Balancer"
    url         = "http://${google_compute_global_address.website_ip[0].address}/"
    behavior    = "✅ Serves index.html automatically for root URL, ✅ Custom 404 pages, ✅ Global CDN"
    cost_impact = "💰 Additional cost for Load Balancer and CDN"
    } : {
    type        = "Direct GCS"
    url         = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/"
    behavior    = "❌ Returns XML bucket listing for root URL, ❌ XML errors for missing pages"
    cost_impact = "💚 Storage costs only"
  }
}

# Load Balancer specific outputs (only when enabled)
output "load_balancer_ip" {
  description = "The IP address of the load balancer (only when enabled)"
  value       = var.enable_load_balancer ? google_compute_global_address.website_ip[0].address : null
}

# Direct GCS endpoints (always available)
output "gcs_direct_urls" {
  description = "Direct GCS URLs for file access"
  value = {
    index_html = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/index.html"
    error_html = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/404.html"
    styles_css = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/styles.css"
  }
}
