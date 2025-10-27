
# ==============================================================================
# INPUTS (The Public Interface of the Module) - TEMPLATE
#
# This file defines the variables for the '__MODULE_NAME__' module.
# Replace '__MODULE_NAME__' with the actual module name.
# ==============================================================================

# ------------------------------------------------------------------------------
# Naming and Location Inputs
# These variables provide context for naming and placing the resources.
# ------------------------------------------------------------------------------

variable "customer_code" {
  description = "A short unique code for the context (e.g., 'gaixer')."
  type        = string
}

variable "role" {
  description = "A short name describing the function of the main resource in this module (e.g., 'app-data', 'main-db')."
  type        = string
}

variable "environment" {
  description = "The full name of the environment (e.g., 'development')."
  type        = string
}

variable "location" {
  description = "The Azure location where the resources will be created."
  type        = string
}


# ------------------------------------------------------------------------------
# Core Resource Inputs
# ------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
  type        = string
}


# ------------------------------------------------------------------------------
# Template-Specific Control Variable
# This variable is used only within the template's example files to differentiate
# test cases. It can be removed when implementing a real module.
# ------------------------------------------------------------------------------
variable "test_case_name" {
  description = "A name for the test case, used to create unique resource names within the example."
  type        = string
  default     = "basic"
}


# ------------------------------------------------------------------------------
# TODO: Add module-specific variables below
# ------------------------------------------------------------------------------
/*
variable "example_optional_variable" {
  description = "An example of a module-specific variable."
  type        = string
  default     = "example_value"
}
*/
