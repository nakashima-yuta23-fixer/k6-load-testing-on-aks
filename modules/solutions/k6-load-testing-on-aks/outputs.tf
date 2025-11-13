# ==============================================================================
# OUTPUTS (The Public Contract of the Module)
#
# Provides key attributes of the created Container App Environment and its
# associated resources, making them easily consumable by other modules.
# ==============================================================================

# AKS
output "object_id_of_managed_id_for_aks" {
  description = "Object ID of system-assigned managed identity for AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "location" {
  value = var.location_debug
}
