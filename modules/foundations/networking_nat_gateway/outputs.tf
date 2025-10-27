# ==============================================================================
# OUTPUTS (The Public Contract of the Module)
#
# Provides attributes of the created NAT Gateway, making them easily
# consumable by other modules (e.g., for creating VMs or private endpoints).
# ==============================================================================

output "vnet_id" {
  description = "The ID of the created NAT Gateway."
  value       = azurerm_nat_gateway.this
}
