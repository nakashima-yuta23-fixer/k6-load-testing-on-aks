# ==============================================================================
# Terraform and Provider Version Constraints
# ==============================================================================

terraform {
  required_version = "~> 1.13" # Adjust to your project's standard version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.45" # Adjust to your project's standard version
    }

    # TODO: Add any other providers this module might need (e.g., random, time).
  }
}
