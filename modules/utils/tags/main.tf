# ==============================================================================
# Standardized Tag Generation Module
#
# This module generates a standardized set of tags based on provided inputs
# and merges them with any custom tags. It ensures consistency in tagging
# across all resources managed by Terraform.
# ==============================================================================


# ------------------------------------------------------------------------------
# INPUTS (The Public Interface of the Module)
#
# These variables provide the necessary context to generate standard tags.
# ------------------------------------------------------------------------------

variable "customer_code" {
  description = "A short unique code representing the customer or context (e.g., 'gaixer'). This is used to populate the 'customer_code' tag."
  type        = string
}

variable "role" {
  description = "A short name describing the primary function of the resource (e.g., 'platform-rg', 'app-vnet'). This is used to populate the 'role' tag."
  type        = string
}

variable "environment" {
  description = "The full name of the environment (e.g., 'development'). This is used to populate the 'environment' tag."
  type        = string
}

variable "custom_tags" {
  description = "A map of any additional, custom tags to be merged with the standard tags. Custom tags will override standard tags if keys conflict."
  type        = map(string)
  default     = {}
}


# ------------------------------------------------------------------------------
# LOGIC (The Internal Implementation)
#
# The logic defines the standard set of tags and then merges them with custom tags.
# ------------------------------------------------------------------------------

locals {
  # --- 1. Define Standard Tags ---
  # These are the tags that should be applied to all resources by default.
  # Keys are in lowercase_snake_case for consistency and automation-friendliness.
  # Values are formatted for better readability in the Azure Portal.
  standard_tags = {
    managed_by    = "Terraform"
    customer_code = var.customer_code
    environment   = title(var.environment)
    role          = title(replace(var.role, "-", " "))
  }

  # --- 2. Merge with Custom Tags ---
  # The merge function combines the two maps. If a key exists in both, the
  # value from the second map (var.custom_tags) takes precedence.
  final_tags = merge(
    local.standard_tags,
    var.custom_tags
  )
}


# ------------------------------------------------------------------------------
# OUTPUTS (The Public Contract of the Module)
# ------------------------------------------------------------------------------

output "result" {
  description = "The final, merged map of standard and custom tags to be applied to a resource."
  value       = local.final_tags
}
