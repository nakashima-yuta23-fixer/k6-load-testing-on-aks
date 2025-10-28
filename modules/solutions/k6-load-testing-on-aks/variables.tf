# ==============================================================================
# INPUTS (The Public Interface of the Module)
#
# This file defines the variables that can be passed to the
# workload_container_app_environment module.
# ==============================================================================

# ------------------------------------------------------------------------------
# Naming and Tagging Inputs
# ------------------------------------------------------------------------------

variable "customer_code" {
  description = "A short unique code for the customer or context. This value is passed to the naming module."
  type        = string
}

variable "role" {
  description = "A short name describing the primary role of this environment (e.g., 'apps', 'platform'). This value is passed to the naming module."
  type        = string
}

variable "environment" {
  description = "The full name of the environment (e.g., 'development', 'production')."
  type        = string
}

variable "location" {
  description = "The official full Azure location name for this resource group. This value is passed to the naming module."
  type        = string
}

# ------------------------------------------------------------------------------
# Virtual Network
# ------------------------------------------------------------------------------

variable "vnet_address_space" {
  description = "A list of CIDR blocks for the VNet (e.g., [\"10.0.0.0/16\"])."
  type        = list(string)
}

variable "snet_address_prefixes_gateway_k8s" {
  description = "A list of CIDR blocks for the workload subnet (e.g., [\"10.10.1.0/24\"])."
  type        = list(string)
}

variable "snet_address_prefixes_cluster_k8s" {
  description = "A list of CIDR blocks for the privatelink subnet (e.g., [\"10.10.2.0/24\"])."
  type        = list(string)
}

# ------------------------------------------------------------------------------
# NAT Gateway
# ------------------------------------------------------------------------------

variable "nat_gateway_sku_name" {
  description = "This variable is the sku name of the NAT Gateway."
  type        = string
}

variable "nat_gateway_idle_timeout_in_minutes" {
  description = "This variable is the NAT gateway idle timeout (in minutes)."
  type        = string
}
