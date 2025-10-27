# ------------------------------------------------------------------------------
# LOGIC
# This module creates a resource group with standardized naming and governance,
# including mandatory tags, optional delete locks, and tag inheritance policies.
# ------------------------------------------------------------------------------

# Call the central naming module to get a consistent resource name.
module "naming" {
  source = "../../utils/naming"

  resource_type = "resource_group"
  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  location      = var.location
}

# Call the central tags module to generate tags to be assigned to resources.
module "tags" {
  source = "../../utils/tags"

  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  custom_tags   = var.custom_tags
}

# Create the resource group with standardized and formatted tags.
resource "azurerm_resource_group" "this" {
  name     = module.naming.kebab
  location = var.location
  tags     = module.tags.result
}

# Apply a delete lock if enabled.
resource "azurerm_management_lock" "delete_lock" {
  count = var.enable_delete_lock ? 1 : 0

  name       = "${module.naming.kebab}-delete-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "This resource group is protected from accidental deletion by Terraform."

  depends_on = [
    azurerm_resource_group.this,
    azurerm_role_assignment.policy_identity_tag_contributor
  ]
}

# --- Tag Inheritance Policy Logic ---

# Look up the built-in policy definition for inheriting a single tag.
data "azurerm_policy_definition" "inherit_tag_from_rg" {
  count = var.enable_tag_inheritance_policy ? 1 : 0

  display_name = "Inherit a tag from the resource group"
}

# Use for_each to iterate over the list of tag names and create a policy assignment for each.
resource "azurerm_resource_group_policy_assignment" "inherit_tags" {
  for_each = var.enable_tag_inheritance_policy ? toset(keys(module.tags.result)) : toset([])

  name                 = "${module.naming.kebab}-inherit-tag-${lower(replace(each.key, "_", "-"))}"
  resource_group_id    = azurerm_resource_group.this.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag_from_rg[0].id

  parameters = jsonencode({
    "tagName" = {
      # The policy parameter expects the exact tag key name.
      value = each.key
    }
  })

  # Create a system-assigned managed identity for this policy assignment.
  # This identity is required for the 'modify' effect to work.
  identity {
    type = "SystemAssigned"
  }

  # The location of the policy assignment must be specified when an identity is used.
  location = var.location
}

# Grant the 'Tag Contributor' role to the managed identity of each policy assignment.
resource "azurerm_role_assignment" "policy_identity_tag_contributor" {
  for_each = azurerm_resource_group_policy_assignment.inherit_tags

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Tag Contributor"
  principal_id         = each.value.identity[0].principal_id
}
