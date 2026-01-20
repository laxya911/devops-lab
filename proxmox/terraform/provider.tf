################################################################################
# PROXMOX PROVIDER CONFIGURATION
# This file configures Terraform to work with Proxmox VE (using Telmate/proxmox)
################################################################################

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

# Configure the Proxmox Provider
provider "proxmox" {
  # URL of your Proxmox API (e.g., https://192.168.0.20:8006/api2/json)
  pm_api_url = var.pm_api_url

  # Credentials (set via variables or env vars)
  pm_user     = var.pm_user
  pm_password = var.pm_password

  # API Token Authentication
  # pm_api_token_id     = var.pm_api_token_id
  # pm_api_token_secret = var.pm_api_token_secret

  # Optional: Skip TLS verification for self-signed certs (common in homelabs)
  pm_tls_insecure = true

  # Debug Logging (Enable to see API calls and specific errors)
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
  }
}
