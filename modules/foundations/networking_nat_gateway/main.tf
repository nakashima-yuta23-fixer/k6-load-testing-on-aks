# ==============================================================================
# LOGIC (The Internal Implementation)
#
# This file contains the core logic for creating the NAT Gateway.
# ==============================================================================

# ------------------------------------------------------------------------------
# Naming
# ------------------------------------------------------------------------------

module "nat_gateway_naming" {
  source = "../../utils/naming"

  resource_type = "nat_gateway"
  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  location      = var.location
}

# ------------------------------------------------------------------------------
# Resource Creation: NAT Gateway
# ------------------------------------------------------------------------------

resource "azurerm_nat_gateway" "this" {
  name                    = module.nat_gateway_naming.kebab
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
}

# resource "azurerm_nat_gateway_public_ip_association" "this" {
#   nat_gateway_id       = azurerm_nat_gateway.this.id
#   public_ip_address_id = 
# }
