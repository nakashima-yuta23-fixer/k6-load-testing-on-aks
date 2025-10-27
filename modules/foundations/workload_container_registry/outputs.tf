# ==============================================================================
# OUTPUTS (The Public Contract of the Module)
#
# Provides key attributes of the created Azure Container Registry, making them
# easily consumable by CI/CD pipelines and other modules.
# ==============================================================================

output "id" {
  description = "The ID of the created Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "The name of the created Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The FQDN of the login server for the Container Registry, used for 'docker login'."
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "The username for the admin account. This will be null if admin_enabled is false."
  value       = azurerm_container_registry.this.admin_username
  # Note: Admin user is not recommended for production.
}

output "admin_password" {
  description = "The password for the admin account. This is a sensitive value."
  value       = azurerm_container_registry.this.admin_password
  sensitive   = true # CRITICAL: Prevents the password from being displayed in logs.
}
