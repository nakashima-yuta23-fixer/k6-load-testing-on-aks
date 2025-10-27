# ------------------------------------------------------------------------------
# OUTPUTS
# Provides attributes of the created resource group for other modules to use.
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the created resource group."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "The name of the created resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "The location of the created resource group."
  value       = azurerm_resource_group.this.location
}

output "tags" {
  description = "All tags applied to the resource group."
  value       = azurerm_resource_group.this.tags
}
