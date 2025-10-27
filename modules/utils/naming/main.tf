# ==============================================================================
# Naming Convention Module
# ==============================================================================


# ------------------------------------------------------------------------------
# INPUTS (The Public Interface of the Module)
#
# The order of variables matches the logical order of the naming convention.
# This improves readability and makes the module's usage intuitive.
# ------------------------------------------------------------------------------

variable "resource_type" {
  description = "The simple, human-readable name of the resource type (e.g., resource_group, storage_account)."
  type        = string
}

variable "customer_code" {
  description = "A short and unique code representing the customer or context of the resource. Examples: 'gaixer' for project-wide resources, 'shared' for the multi-tenant environment, 'fixer' for dogfooding, and a customer-specific code (e.g., 'custa' for Customer-A) for dedicated environments."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,6}$", var.customer_code))
    error_message = "The 'customer_code' must be between 3 and 6 lowercase alphanumeric characters."
  }
}

variable "role" {
  description = "A short name describing the function or role of the resource (e.g., central, web, api)."
  type        = string
  validation {
    condition     = length(var.role) >= 3 && length(var.role) <= 12
    error_message = "The 'role' must be between 3 and 12 characters."
  }
}

variable "environment" {
  description = "The official full name of the environment (e.g., development, staging, production)."
  type        = string
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "The 'environment' must be one of: development, staging, or production."
  }
}

variable "location" {
  description = "The official full Azure location name (e.g., japaneast, eastus). Set to null for global resources."
  type        = string
  nullable    = true
  default     = null
}


# ------------------------------------------------------------------------------
# LOGIC (The Internal Implementation)
#
# The order of locals follows the logical flow of data:
# 1. Define Maps -> 2. Look up Abbreviations -> 3. Assemble Parts -> 4. Generate Final Names
# ------------------------------------------------------------------------------

locals {
  # ==============================================================================
  # Abbreviation Maps
  # The single source of truth for all naming abbreviations.
  # ==============================================================================
  resource_type_map = {
    # General & Management
    resource_group          = "rg"
    log_analytics_workspace = "log"
    application_insights    = "appi"
    automation_account      = "aa"
    data_collection_rule    = "dcr"

    # Security
    key_vault           = "kv"
    managed_identity    = "id"
    disk_encryption_set = "des"
    ssh_key             = "sshkey"
    waf_policy          = "waf"

    # Networking
    virtual_network            = "vnet"
    subnet                     = "snet"
    network_interface          = "nic"
    network_security_group     = "nsg"
    route_table                = "rt"
    public_ip_address          = "pip"
    private_endpoint           = "pep"
    private_link               = "pl"
    nat_gateway                = "ng"
    application_gateway        = "agw"
    azure_firewall             = "afw"
    azure_firewall_policy      = "afwp"
    front_door_profile         = "afd"
    front_door_endpoint        = "fde"
    front_door_firewall_policy = "fdfp"
    expressroute_circuit       = "erc"
    vnet_gateway               = "vgw"
    expressroute_gateway       = "ergw"
    vnet_peering               = "peer"

    # Compute & Web
    virtual_machine       = "vm"
    vm_os_disk            = "osdisk"
    vm_data_disk          = "disk"
    vm_maintenance_config = "mc"
    app_service_plan      = "asp"
    web_app               = "app"
    static_web_app        = "stapp"
    function_app          = "func"

    # Containers
    aks_cluster               = "aks"
    aks_system_node_pool      = "npsystem"
    aks_user_node_pool        = "np"
    container_registry        = "cr"
    container_instance        = "ci"
    container_app_environment = "cae"

    # Databases
    sql_server        = "sql"
    sql_database      = "sqldb"
    sql_elastic_pool  = "sqlep"
    postgresql_server = "psql"
    mysql_server      = "mysql"
    cosmosdb_account  = "cosmos"
    redis_cache       = "redis"

    # Storage
    storage_account = "st"

    # Analytics & IoT
    eventhubs_namespace = "evhns"
    eventhub            = "evh"

    # AI + Machine Learning
    azure_openai_service  = "oai"
    bot_service           = "bot"
    document_intelligence = "di"
    speech_service        = "spch"

    # Developer & Integration Tools
    app_configuration_store = "appcs"
    api_management_service  = "apim"
    logic_app               = "logic"
    web_pubsub_service      = "wps"

    # Migration & Disaster Recovery
    recovery_services_vault = "rsv"
  }

  environment_map = {
    "development" = "dv"
    "staging"     = "st"
    "production"  = "pr"
  }

  location_map = {
    "japaneast" = "je"
    "japanwest" = "jw"
    "eastus"    = "eus"
    "eastus2"   = "eus2"
    "westus"    = "wus"
    "westus2"   = "wus2"
    "centralus" = "cus"
  }

  # ==============================================================================
  # Naming Constraint Definitions
  # A map defining character limits for specific resource types.
  # ==============================================================================
  char_limit_map = {
    "storage_account" = 24
    "key_vault"       = 24
    // "another_resource_type"   = 63
  }


  # ==============================================================================
  # Dynamic Name Generation
  # These sections assemble the final names based on the inputs and rules above.
  # ==============================================================================

  # --- 1. Abbreviation Lookups ---
  resource_type_abbreviation = lookup(local.resource_type_map, var.resource_type)
  environment_abbreviation   = lookup(local.environment_map, var.environment)
  location_abbreviation      = var.location == null ? null : lookup(local.location_map, var.location)

  # --- 2. Name Assembly ---
  name_parts = compact([
    local.resource_type_abbreviation,
    var.customer_code,
    var.role,
    local.environment_abbreviation,
    local.location_abbreviation,
  ])

  # --- 3. Final Generated Names ---
  kebab_case   = lower(join("-", local.name_parts))
  compact_case = lower(join("", local.name_parts))
}


# ------------------------------------------------------------------------------
# OUTPUTS (The Public Contract of the Module)
# ------------------------------------------------------------------------------

output "kebab" {
  description = "The standard kebab-case name for the resource (e.g., rg-gaixer-web-pr-je). For unsupported resource types, this gracefully falls back to the 'compact' name."
  value       = local.kebab_case
}

output "compact" {
  description = "The compact name with no hyphens, for resources with strict naming constraints."
  value       = local.compact_case

  precondition {
    # Check if the generated name exceeds the character limit for applicable resource types.
    condition     = length(local.compact_case) <= lookup(local.char_limit_map, var.resource_type, 90)
    error_message = "The generated compact name '${local.compact_case}' (${length(local.compact_case)} chars) exceeds the maximum length of ${lookup(local.char_limit_map, var.resource_type, "N/A")} for resource type '${var.resource_type}'. Please shorten the input parts."
  }
}
