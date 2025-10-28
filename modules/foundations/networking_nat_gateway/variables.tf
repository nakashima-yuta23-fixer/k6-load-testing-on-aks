# ==============================================================================
# INPUTS (The Public Interface of the Module)
# ==============================================================================

# --- Naming and Tagging Inputs ---
variable "customer_code" {
  description = "A short unique code for the customer or context. This value is passed to the naming module."
  type        = string
}

variable "role" {
  description = "A short name describing the primary role of this VNet (e.g., hub, spoke, app). This value is passed to the naming module."
  type        = string
}

variable "environment" {
  description = "The full name of the environment for this VNet. This value is passed to the naming module."
  type        = string
}

# --- Core Resource Inputs ---
variable "resource_group_name" {
  description = "The name of the resource group where the VNet will be created."
  type        = string
}

variable "location" {
  description = "The Azure location where the VNet will be created."
  type        = string
}

variable "is_ip_address_prefix" {
  description = "The flag indicating whether it is an IP address prefix."
  type        = bool
}

variable "subnet_id" {
  description = "The subnet to be associated with the NAT Gateway ID."
  type        = list(string)
}
