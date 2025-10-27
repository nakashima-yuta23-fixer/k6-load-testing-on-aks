# ==============================================================================
# OUTPUTS (The Public Contract of the Module) - TEMPLATE
#
# Provides key attributes of the created resources for consumption by other modules.
# ==============================================================================

# TODO: Define the actual outputs for this module. At a minimum, 'id' and 'name' are recommended.
# Replace the placeholder values with actual resource attributes.
# e.g., value = azurerm_example_resource.this.id

output "id" {
  description = "The ID of the main resource created by this module."
  # This is a placeholder value. Update it to reference your main resource's id.
  value = null_resource.placeholder.id
}

output "name" {
  description = "The name of the main resource created by this module."
  # This is a placeholder value. Update it to reference your main resource's name.
  value = null_resource.placeholder.triggers
}
