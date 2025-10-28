# ==============================================================================
# LOGIC (The Internal Implementation)
#
# This file contains the core logic for creating the NAT Gateway and public IP address, associating NAT Gateway with public IP address and NAT Gateway with one or more subnets.
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

module "public_ip_address_naming" {
  source = "../../utils/naming"

  resource_type = "public_ip_address"
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
  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
}

# ------------------------------------------------------------------------------
# Resource Creation: Public IP
# ------------------------------------------------------------------------------

resource "azurerm_public_ip" "public_ip" {
  count               = var.is_ip_address_prefix ? 0 : 1
  name                = module.public_ip_address_naming.kebab
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip_prefix" "public_ip_prefix" {
  count               = var.is_ip_address_prefix ? 1 : 0
  name                = module.public_ip_address_naming.kebab
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
}

# ------------------------------------------------------------------------------
# Resource Creation: Manages the association between a NAT Gateway and a Public IP
# ------------------------------------------------------------------------------

resource "azurerm_nat_gateway_public_ip_association" "public_ip_association" {
  count                = var.is_ip_address_prefix ? 0 : 1
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.public_ip[0].id
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "public_ip_prefix_association" {
  count               = var.is_ip_address_prefix ? 1 : 0
  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.public_ip_prefix[0].id
}

# ------------------------------------------------------------------------------
# Resource Creation: Manages the association between a NAT Gateway and a Subnet
# ------------------------------------------------------------------------------

resource "azurerm_subnet_nat_gateway_association" "subnet_association" {
  count          = length(var.subnet_id)
  subnet_id      = var.subnet_id[count.index]
  nat_gateway_id = azurerm_nat_gateway.this.id
}
