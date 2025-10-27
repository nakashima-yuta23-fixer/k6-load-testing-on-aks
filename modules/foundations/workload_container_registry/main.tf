# ==============================================================================
# LOGIC (The Internal Implementation)
#
# This module provisions a highly configurable Azure Container Registry (ACR).
# Tagging is handled centrally by Azure Policy, assigned at the resource group level.
# ==============================================================================

# ------------------------------------------------------------------------------
# Naming
# ------------------------------------------------------------------------------

module "naming" {
  source = "../../utils/naming"

  resource_type = "container_registry"
  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  location      = var.location
}

# ------------------------------------------------------------------------------
# Local Variables for Conditional Logic
# ------------------------------------------------------------------------------

locals {
  is_premium_sku = var.sku == "Premium"

  # Determine if optional blocks should be created
  create_identity_block       = var.identity_type != null
  create_encryption_block     = var.encryption_key_id != null
  create_network_rule_block   = local.is_premium_sku && var.network_rule_set != null
  create_georeplication_block = local.is_premium_sku && length(var.georeplications) > 0
}


# ------------------------------------------------------------------------------
# Resource Creation: Azure Container Registry
# ------------------------------------------------------------------------------

resource "azurerm_container_registry" "this" {
  # --- General Settings ---
  name                = module.naming.compact
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # --- Optional Blocks ---

  # Identity Block (for user-assigned identity)
  dynamic "identity" {
    for_each = local.create_identity_block ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Encryption Block (for customer-managed keys)
  dynamic "encryption" {
    for_each = local.create_encryption_block ? [1] : []
    content {
      key_vault_key_id   = var.encryption_key_id
      identity_client_id = var.identity_client_id_for_encryption
    }
  }

  # --- Premium SKU Specific Settings ---

  # These arguments are set to their respective variable values if the SKU is Premium,
  # otherwise they are set to null, which causes Terraform to ignore them.
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = local.is_premium_sku ? var.zone_redundancy_enabled : null
  quarantine_policy_enabled     = local.is_premium_sku ? var.quarantine_policy_enabled : null
  export_policy_enabled         = local.is_premium_sku ? var.export_policy_enabled : null
  data_endpoint_enabled         = local.is_premium_sku ? var.data_endpoint_enabled : null
  anonymous_pull_enabled        = local.is_premium_sku ? var.anonymous_pull_enabled : null

  # Network Rule Set Block (Premium only)
  dynamic "network_rule_set" {
    for_each = local.create_network_rule_block ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action
      ip_rule = [for ip in network_rule_set.value.ip_rules : {
        action   = "Allow"
        ip_range = ip
      }]
    }
  }

  # Georeplications Block (Premium only)
  dynamic "georeplications" {
    for_each = local.create_georeplication_block ? var.georeplications : []
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      tags                      = georeplications.value.tags
    }
  }

  # Retention Policy (part of the resource block, not a dynamic block)
  retention_policy_in_days = local.is_premium_sku && var.retention_policy_enabled ? var.retention_policy_days : null

  # Trust Policy
  trust_policy_enabled = local.is_premium_sku ? var.trust_policy_enabled : false

  # Lifecycle block to ignore changes to tags made by external systems (e.g., Azure Policy)
  lifecycle {
    ignore_changes = [tags]
  }
}
