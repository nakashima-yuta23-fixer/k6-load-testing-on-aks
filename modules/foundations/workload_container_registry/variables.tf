# ==============================================================================
# INPUTS (The Public Interface of the Module)
#
# This file defines the variables that can be passed to the
# workload_container_registry module.
# ==============================================================================

# ------------------------------------------------------------------------------
# Naming Inputs
# These variables are passed to the central naming module.
# ------------------------------------------------------------------------------

variable "customer_code" {
  description = "A short unique code for the context (e.g., 'gaixer')."
  type        = string
}

variable "role" {
  description = "A short name describing the primary function of this ACR (e.g., 'platform', 'apps')."
  type        = string
}

variable "environment" {
  description = "The full name of the environment (e.g., 'development')."
  type        = string
}

variable "location" {
  description = "The Azure location where the resources will be created."
  type        = string
}


# ------------------------------------------------------------------------------
# Core Resource Inputs
# ------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group where the ACR will be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Container Registry. Allowed values are Basic, Standard, or Premium."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The SKU must be one of: Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled. Not recommended for production environments."
  type        = bool
  default     = false
}

# --- Identity and Encryption ---
variable "identity_type" {
  description = "The type of managed identity to assign. e.g., 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'. Null if not needed."
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "A list of User-Assigned Identity IDs to assign to the ACR. Required if 'identity_type' includes 'UserAssigned'."
  type        = list(string)
  default     = []
}

variable "encryption_key_id" {
  description = "The Key Vault Key ID for customer-managed encryption. If null, encryption is disabled."
  type        = string
  default     = null
}

variable "identity_client_id_for_encryption" {
  description = "The Client ID of the User-Assigned Identity with permissions to the encryption key. Required if using a customer-managed key."
  type        = string
  default     = null
}


# ------------------------------------------------------------------------------
# Premium SKU Specific Inputs
# These variables are only effective when 'sku' is set to "Premium".
# ------------------------------------------------------------------------------

variable "public_network_access_enabled" {
  description = "Whether to allow public network access. Set to false for private-only registries."
  type        = bool
  default     = true
}

variable "zone_redundancy_enabled" {
  description = "Whether to enable zone redundancy. Only available for 'Premium' SKU in supported regions."
  type        = bool
  default     = false
}

variable "quarantine_policy_enabled" {
  description = "Whether to enable the quarantine policy."
  type        = bool
  default     = false
}

variable "trust_policy_enabled" {
  description = "Whether to enable the content trust policy."
  type        = bool
  default     = false
}

variable "retention_policy_enabled" {
  description = "Whether to enable the retention policy for untagged manifests."
  type        = bool
  default     = false
}

variable "retention_policy_days" {
  description = "The number of days to retain untagged manifests. Required if retention policy is enabled."
  type        = number
  default     = 7
}

variable "export_policy_enabled" {
  description = "Whether to enable the export policy."
  type        = bool
  default     = true
}

variable "data_endpoint_enabled" {
  description = "Whether to enable the dedicated data endpoint."
  type        = bool
  default     = false
}

variable "anonymous_pull_enabled" {
  description = "Whether to enable anonymous (unauthenticated) pull access."
  type        = bool
  default     = false
}

variable "network_rule_set" {
  description = "A map defining the network rule set. Only effective for 'Premium' SKU."
  type = object({
    default_action = string
    ip_rules       = list(string)
  })
  default = null
}

variable "georeplications" {
  description = "A list of objects defining georeplications. Only effective for 'Premium' SKU."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default = []
}
