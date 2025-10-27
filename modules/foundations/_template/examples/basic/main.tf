# ==============================================================================
# Basic Example for the '__MODULE_NAME__' Module (Template)
#
# This file serves as a starting point. Before running, you must implement
# the actual module logic and replace the placeholder resources here with
# real Azure resources for testing.
# ==============================================================================

# This example uses the 'null' provider for initial validation without Azure resources.
# TODO: Change this to the 'azurerm' provider when implementing the test.
provider "null" {}

# --- Prerequisite Resource Placeholder ---
# TODO: Replace this with a real 'azurerm_resource_group'.
resource "null_resource" "resource_group_placeholder" {
  triggers = {
    name     = "rg-test-basic-example"
    location = "japaneast"
  }
}

# ------------------------------------------------------------------------------
# Module Invocation (Basic)
# ------------------------------------------------------------------------------
module "__MODULE_NAME__" {
  source = "../../" # Points to the module root (e.g., foundations/_template)

  # --- Test Case Identifier ---
  test_case_name = "basic"

  # --- Required Inputs (using placeholder values) ---
  resource_group_name = null_resource.resource_group_placeholder.triggers.name
  location            = null_resource.resource_group_placeholder.triggers.location
  customer_code       = "test"
  role                = "basic"
  environment         = "development"

  # TODO: Add any other required variables here.
}

# --- Outputs ---
output "basic_output" {
  description = "The placeholder output from the basic test case."
  value       = module.__MODULE_NAME__.name
}
