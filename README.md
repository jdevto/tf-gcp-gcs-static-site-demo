# Terraform GCS Static Website Demo

A flexible Terraform configuration for hosting static websites on Google Cloud Storage with **two deployment options**: Direct GCS (simple & free) or Load Balancer (professional behavior).

## 🎯 Two Deployment Options

| Option | Cost | Behavior | Best For |
|--------|------|----------|----------|
| **Direct GCS** | 💚 ~$0.026/month | Files accessible, root URL returns XML | Learning, Development |
| **Load Balancer** | 💰 ~$18-25/month | Root URL serves index.html, custom 404s | Production, Demos |

👉 **See [DEPLOYMENT_OPTIONS.md](DEPLOYMENT_OPTIONS.md) for detailed comparison**

## 🚀 Quick Start

### 1. Configure

Update `terraform.tfvars`:

```hcl
project_id            = "your-project-id"
region                = "us-central1"
bucket_name           = "your-unique-bucket-name"
website_name          = "My Static Website"
enable_load_balancer  = false  # true for proper website behavior
```

### 2. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 3. Access

Check your deployment type and URL:

```bash
# See what was deployed
terraform output setup_type
terraform output website_url

# Get detailed endpoint information
terraform output website_endpoint_info
```

## 📋 Configuration Options

### Direct GCS (Default - Free Tier)

```hcl
enable_load_balancer = false
```

- ✅ Simple setup (5 resources)
- ✅ Stays in free tier
- ❌ Root URL returns XML
- ❌ No custom 404 pages

### Load Balancer (Professional)

```hcl
enable_load_balancer = true
```

- ✅ Root URL serves index.html
- ✅ Custom 404.html pages
- ✅ Global CDN
- ✅ Static IP
- ❌ Additional costs (~$18-25/month)

## 🔧 Prerequisites

### For Direct GCS

- Google Cloud Project with billing enabled
- Terraform (1.0+)
- Service account with `roles/storage.admin`

### For Load Balancer

- All Direct GCS requirements plus:
- Service account with `roles/compute.networkAdmin`
- Service account with `roles/compute.loadBalancerAdmin`

## 📊 Example Outputs

### Direct GCS Output

```plaintext
setup_type = "Direct GCS"
website_url = "https://storage.googleapis.com/my-bucket/index.html"
website_endpoint_info = {
  "behavior" = "❌ Returns XML bucket listing for root URL"
  "cost_impact" = "💚 Storage costs only"
  "type" = "Direct GCS"
  "url" = "https://storage.googleapis.com/my-bucket/"
}
```

### Load Balancer Output

```plaintext
setup_type = "Load Balancer"
website_url = "http://203.0.113.1/"
website_endpoint_info = {
  "behavior" = "✅ Serves index.html automatically for root URL"
  "cost_impact" = "💰 Additional cost for Load Balancer and CDN"
  "type" = "Load Balancer"
  "url" = "http://203.0.113.1/"
}
```

## 🔄 Switching Between Options

Change the variable in `terraform.tfvars` and run:

```bash
terraform apply
```

Terraform will automatically create or destroy the Load Balancer resources as needed.

## 🛠️ Files

- `main.tf` - Main Terraform configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `versions.tf` - Provider versions
- `static/` - Website files (HTML, CSS)
- `DEPLOYMENT_OPTIONS.md` - Detailed comparison guide

## 🧹 Cleanup

```bash
terraform destroy
```

**Note**: This will delete all resources including the bucket and its contents.

## 📚 Learn More

- 📖 [DEPLOYMENT_OPTIONS.md](DEPLOYMENT_OPTIONS.md) - Detailed comparison and cost analysis
- 🔗 [Google Cloud Static Website Hosting](https://cloud.google.com/storage/docs/hosting-static-website)
- 🔗 [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
