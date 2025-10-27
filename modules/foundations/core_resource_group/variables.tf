# ------------------------------------------------------------------------------
# INPUTS
# Defines the parameters required to create a governed resource group.
# For detailed definitions and allowed values for naming-related variables
# (customer_code, role, environment, location), please refer to the central
# 'naming' module documentation.
# ------------------------------------------------------------------------------

variable "customer_code" {
  description = "A short and unique code representing the customer or context for this resource group. This value is passed to the naming module."
  type        = string
}

variable "role" {
  description = "A short name describing the function or role of this resource group. This value is passed to the naming module."
  type        = string
}

variable "environment" {
  description = "The official full name of the environment for this resource group. This value is passed to the naming module."
  type        = string
}

variable "location" {
  description = "The official full Azure location name for this resource group. This value is passed to the naming module."
  type        = string
}

variable "custom_tags" {
  description = "A map of custom tags to be applied to the resource group, in addition to the mandatory tags. Keys should be in lowercase snake_case."
  type        = map(string)
  default     = {}
}

variable "enable_delete_lock" {
  description = "If set to true, a 'CanNotDelete' lock will be applied to the resource group to prevent accidental deletion."
  type        = bool
  default     = false
}

variable "enable_tag_inheritance_policy" {
  description = "If set to true, assigns policies to inherit ALL tags from this resource group."
  type        = bool
  default     = false
}
