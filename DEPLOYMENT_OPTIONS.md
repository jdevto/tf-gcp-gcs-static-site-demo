# GCS Static Website Deployment Options

This document explains the two deployment options available for hosting static websites on Google Cloud Storage, their behaviors, and cost implications.

## 🚀 Quick Comparison

| Feature | Direct GCS | Load Balancer |
|---------|------------|---------------|
| **Resources** | 5 resources | 12 resources |
| **Root URL behavior** | ❌ Returns XML bucket listing | ✅ Serves index.html automatically |
| **404 handling** | ❌ Returns XML errors | ✅ Serves custom 404.html |
| **CDN** | ❌ No CDN | ✅ Global CDN |
| **Static IP** | ❌ No static IP | ✅ Static IP address |
| **Setup complexity** | ✅ Simple | ⚠️ More complex |
| **Cost (Free Tier)** | 💚 ~$0.026/month | 💰 ~$18-25/month |
| **Best for** | Learning/Development | Production websites |

## 📋 Option 1: Direct GCS (Default)

### Direct GCS Configuration

```hcl
enable_load_balancer = false  # Default
```

### Direct GCS Resources Created

- `google_storage_bucket` - Storage bucket with website configuration
- `google_storage_bucket_iam_binding` - Public read access
- `google_storage_bucket_object` × 3 - HTML and CSS files
- `google_project_service` - Storage API enablement

### Direct GCS Behavior

**✅ What Works:**

- Direct file access: `https://storage.googleapis.com/bucket-name/index.html`
- Files are publicly accessible
- CSS and assets load properly
- Fast and simple deployment

**❌ What Doesn't Work:**

- Root URL (`https://storage.googleapis.com/bucket-name/`) returns XML bucket listing
- Missing pages return XML errors instead of custom 404.html
- No CDN acceleration
- No static IP address

### Direct GCS Testing

```bash
# Deploy with direct GCS
terraform apply

# Test direct file access (works)
curl $(terraform output -raw gcs_direct_urls | jq -r '.index_html')

# Test root URL (returns XML)
curl "https://storage.googleapis.com/$(terraform output -raw bucket_name)/"
```

## 🏗️ Option 2: Load Balancer

### Load Balancer Configuration

```hcl
enable_load_balancer = true
```

### Load Balancer Resources Created

**All Direct GCS resources plus:**

- `google_project_service` - Compute Engine API enablement
- `google_compute_backend_bucket` - Backend bucket configuration
- `google_compute_global_address` - Static IP address
- `google_compute_url_map` - URL routing
- `google_compute_target_http_proxy` - HTTP proxy
- `google_compute_global_forwarding_rule` - Traffic forwarding

### Load Balancer Behavior

**✅ What Works:**

- Root URL serves index.html automatically
- Custom 404.html for missing pages
- Global CDN acceleration
- Static IP address
- Professional website behavior
- Proper cache headers

**⚠️ Considerations:**

- More complex setup
- Requires additional API permissions
- Higher costs

### Load Balancer Testing

```bash
# Deploy with Load Balancer
terraform apply

# Test root URL (serves index.html)
curl $(terraform output -raw website_url)

# Test missing page (serves 404.html)
curl "$(terraform output -raw website_url)nonexistent.html"
```

## 💰 Cost Analysis

### Free Tier Considerations

**Google Cloud Always Free Tier includes:**

- 5 GB Cloud Storage
- 1 GB egress per month (Americas)
- 2 million Cloud Functions invocations
- No free tier for Load Balancer or CDN

## 🎯 When to Use Each Option

### Use Direct GCS When

- **Learning Terraform** and GCP concepts
- **Development/testing** environments
- **Budget is critical** (stays in free tier)
- **Simple file hosting** without website behavior requirements
- **Rapid prototyping**

### Use Load Balancer When

- **Production websites** that need proper behavior
- **Professional demos** or client presentations
- **SEO matters** (proper index.html serving)
- **Global audience** (CDN benefits)
- **Budget allows** for additional costs

## 🔧 Switching Between Options

### From Direct GCS to Load Balancer

```bash
# Update terraform.tfvars
echo 'enable_load_balancer = true' >> terraform.tfvars

# Apply changes
terraform apply
```

### From Load Balancer to Direct GCS

```bash
# Update terraform.tfvars
sed -i 's/enable_load_balancer = true/enable_load_balancer = false/' terraform.tfvars

# Apply changes (will destroy Load Balancer resources)
terraform apply
```

## 📊 Performance Comparison

### Direct GCS

- **Latency**: Regional latency (bucket location)
- **Throughput**: Standard GCS performance
- **Availability**: 99.5% SLA
- **Cache**: Browser caching only

### Load Balancer

- **Latency**: Global edge locations (CDN)
- **Throughput**: Higher with CDN
- **Availability**: 99.95% SLA
- **Cache**: CDN + browser caching

## 🛠️ Troubleshooting

### Direct GCS Issues

- **Root URL returns XML**: Expected behavior, use direct file URLs
- **404 errors show XML**: Expected behavior, no custom error pages
- **Slow loading**: No CDN, consider Load Balancer option

### Load Balancer Issues

- **API not enabled**: Run `terraform apply` again after API enablement
- **Permission denied**: Ensure compute.networkAdmin role
- **High costs**: Consider switching to Direct GCS for development

## 🎉 Recommendations

### For Learning/Development

```hcl
enable_load_balancer = false  # Stay in free tier
```

### For Production

```hcl
enable_load_balancer = true   # Proper website behavior
```

### For Demos

- Use Load Balancer if showcasing professional setup
- Use Direct GCS if demonstrating infrastructure concepts

## 📚 Additional Resources

- [GCS Static Website Hosting](https://cloud.google.com/storage/docs/hosting-static-website)
- [Load Balancer Pricing](https://cloud.google.com/load-balancing/pricing)
- [Cloud CDN Pricing](https://cloud.google.com/cdn/pricing)
- [Google Cloud Free Tier](https://cloud.google.com/free)
