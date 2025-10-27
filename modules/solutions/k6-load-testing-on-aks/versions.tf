# ==============================================================================
# Terraform and Provider Version Constraints
#
# Specifies the minimum required versions for Terraform and the AzureRM provider
# to ensure compatibility and predictable behavior of this module.
# ==============================================================================

terraform {
  required_version = "~> 1.12"
  required_providers {
    azurerm = {
      # Reference | https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
      source  = "hashicorp/azurerm"
      version = "~> 4.36"
    }
  }
}
