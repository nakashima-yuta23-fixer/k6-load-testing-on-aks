# ==============================================================================
# OUTPUTS (The Public Contract of the Module)
#
# Provides attributes of the created VNet and subnets, making them easily
# consumable by other modules (e.g., for creating VMs or private endpoints).
# ==============================================================================

output "vnet_id" {
  description = "The ID of the created Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the created Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "The address space of the created Virtual Network."
  value       = azurerm_virtual_network.this.address_space
}

output "subnets" {
  description = "A map of all standard subnets created by the module, keyed by their role name."
  value       = azurerm_subnet.standard
}

output "subnet_ids" {
  description = "A map of standard subnet IDs, keyed by their role name."
  value       = { for k, v in azurerm_subnet.standard : k => v.id }
}

output "special_subnet_ids" {
  description = "A map of IDs for special-purpose subnets like AzureFirewallSubnet and GatewaySubnet."
  value = {
    azure_firewall = try(azurerm_subnet.azure_firewall[0].id, null)
    vnet_gateway   = try(azurerm_subnet.vnet_gateway[0].id, null)
  }
}
