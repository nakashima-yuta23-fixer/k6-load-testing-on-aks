# ==============================================================================
# LOGIC (The Internal Implementation) - TEMPLATE
#
# This module provisions '__MODULE_NAME__'.
# Replace '__MODULE_NAME__' with a short description of what this module does.
# ==============================================================================

# ------------------------------------------------------------------------------
# Naming
#
# TODO: Uncomment this block and set the correct 'resource_type'.
# ------------------------------------------------------------------------------
/*
module "naming" {
  source = "../../utils/naming"

  resource_type = "__RESOURCE_TYPE__" # e.g., "virtual_network", "key_vault"
  role          = "${var.role}-${var.test_case_name}"
  
  customer_code = var.customer_code
  environment   = var.environment
  location      = var.location
}
*/


# ------------------------------------------------------------------------------
# Resource Creation
# ------------------------------------------------------------------------------

# TODO: Replace the placeholder below with the actual Azure resource(s).
# Remember to use the output from the 'naming' module for the 'name' argument.
# e.g., name = module.naming.kebab
resource "null_resource" "placeholder" {
  triggers = {
    warning   = "This is a template module. Please replace this with actual resources and uncomment the 'naming' module block."
    test_case = var.test_case_name
  }
}
