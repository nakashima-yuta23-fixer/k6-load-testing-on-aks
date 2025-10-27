# ==============================================================================
# Advanced Example for the '__MODULE_NAME__' Module (Template)
#
# This file serves as a starting point for testing advanced features.
# Before running, implement the module logic and replace placeholders.
# ==============================================================================

provider "null" {}

# --- Prerequisite Resource Placeholders ---
resource "null_resource" "resource_group_placeholder" {
  triggers = {
    name     = "rg-test-advanced-example"
    location = "japaneast"
  }
}
# TODO: Add other prerequisite placeholders (e.g., a VNet).
resource "null_resource" "dependency_placeholder" {
  triggers = {
    id = "id-of-a-prerequisite-resource"
  }
}

# ------------------------------------------------------------------------------
# Module Invocation (Advanced)
# ------------------------------------------------------------------------------
module "__MODULE_NAME__" {
  source = "../../"

  # --- Test Case Identifier ---
  test_case_name = "advanced"

  # --- Required Inputs ---
  resource_group_name = null_resource.resource_group_placeholder.triggers.name
  location            = null_resource.resource_group_placeholder.triggers.location
  customer_code       = "test"
  role                = "advanced"
  environment         = "production"

  # --- Optional Inputs to test advanced features ---
  # TODO: Uncomment and provide values for optional variables.
  /*
  example_optional_variable = "some-custom-value"
  dependency_id             = null_resource.dependency_placeholder.triggers.id
  */
}

# --- Outputs ---
output "advanced_output" {
  description = "The placeholder output from the advanced test case."
  value       = module.__MODULE_NAME__.name
}
