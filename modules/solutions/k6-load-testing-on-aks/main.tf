# resource group 作成
# Create the resource group with standardized and formatted tags.
resource "azurerm_resource_group" "this" {
  name     = "rg-k6natg-load-testing-dv-je"
  location = var.location
  tags     = {
    "customer_code" = var.customer_code,
    "role" = var.role,
    "environment" = var.environment,
    "solution" = "k6-load-testing-on-aks"
  }
}

# Apply a delete lock if enabled.
resource "azurerm_management_lock" "delete_lock" {
  name       = "${resource.azurerm_resource_group.this.name}-delete-lock"
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
  display_name = "Inherit a tag from the resource group"
}

# Use for_each to iterate over the list of tag names and create a policy assignment for each.
resource "azurerm_resource_group_policy_assignment" "inherit_tags" {
  for_each = toset([var.customer_code, var.role, var.environment, var.location])

  name                 = "${resource.azurerm_resource_group.this.name}-inherit-tag-${lower(replace(each.key, "_", "-"))}"
  resource_group_id    = azurerm_resource_group.this.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag_from_rg.id

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

# vnet/subnet 作成
resource "azurerm_virtual_network" "this" {
  name                = "vnet-k6natg-load-testing-dv-je"
  resource_group_name = azurerm_resource_group.this.id
  location            = var.location
  address_space       = var.vnet_address_space

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "standard" {
  name                 = "snet-k6natg-cluster-k8s-dv-je"
  resource_group_name  = azurerm_resource_group.this.id
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.snet_address_prefixes_cluster_k8s

  service_endpoints                 = []
  private_endpoint_network_policies = "Disabled"
}

# nsg 作成

# peering 作成 (prometheus でメトリックを Grafana にエクスポートするため)

# acr 作成
# TODO: foudationsモジュールから呼び出せるようにする。
resource "azurerm_container_registry" "this" {
  name                = "crk6testloadtestingdvje"
  resource_group_name = azurerm_resource_group.this.id
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false

  lifecycle {
    ignore_changes = [tags]
  }
}

# aks クラスター作成
# TODO: foudationsモジュールから呼び出せるようにする。
resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-load-testing-dv-je"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.id
  dns_prefix          = "aks-load-testing-dv-je-dns"

  default_node_pool {
    name                 = "npsystem"
    node_count           = 2
    vm_size              = "Standard_D8ls_v5"
    auto_scaling_enabled = false
    max_pods             = 110
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    type                 = "VirtualMachineScaleSets"
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
    vnet_subnet_id = resource.azurerm_virtual_network.this.id
    zones          = [1]
  }

  api_server_access_profile {
    authorized_ip_ranges = ["202.211.86.16/32"]
  }

  identity {
    type = "SystemAssigned"
  }

  image_cleaner_enabled = false # 負荷試験実行基盤用のAKSは負荷試験が終わり次第クラスターを削除する予定のため

  # 常に最新バージョンを使用するため、kubernetes_versionは指定せず常に最新バージョンでAKSを構築する。
  # kubernetes_version = "x.x.x"

  local_account_disabled = false

  network_profile {
    network_plugin      = "azure"
    network_data_plane  = "azure"
    network_plugin_mode = "overlay"
  }

  bootstrap_profile {
    artifact_source = "Direct"
  }

  node_os_upgrade_channel = "None"

  oidc_issuer_enabled               = false
  open_service_mesh_enabled         = false
  workload_identity_enabled         = false
  role_based_access_control_enabled = true
  sku_tier                          = "Standard"

  storage_profile {
    blob_driver_enabled         = true
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  support_plan = "KubernetesOfficial"

  lifecycle {
    ignore_changes = [tags]
  }
}

output "object_id_of_managed_id_for_aks" {
  description = "Object ID of system-assigned managed identity for AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

# nat gateway 作成
resource "azurerm_nat_gateway" "this" {
  name                    = "ng-k6natg-load-testing-dv-je"
  resource_group_name     = azurerm_resource_group.this.id
  location                = var.location
  sku_name                = var.nat_gateway_sku_name
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout_in_minutes

  lifecycle {
    ignore_changes = [tags]
  }
}

# public IP Address Prefix 作成
resource "azurerm_public_ip_prefix" "public_ip_prefix" {
  name                = "pip-k6natg-load-testing-dv-je"
  resource_group_name = azurerm_resource_group.this.id
  location            = var.location

  prefix_length       = 30
  sku                 = "Standard"

  lifecycle {
    ignore_changes = [tags]
  }
}

# public IP Address Prefixとnat gateway紐づけ
resource "azurerm_nat_gateway_public_ip_prefix_association" "public_ip_prefix_association" {
  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.public_ip_prefix.id
}

# subnetとnat gateway紐づけ
resource "azurerm_subnet_nat_gateway_association" "subnet_association" {
  subnet_id      = resource.azurerm_subnet.standard.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

# k6-operatorのインストール (helmでインストールしたものもtfstateで管理するのか微妙？頻繁に実行基盤が削除されるのであれば、ｄelete時にhelmでインストールしたものの状態が変更していれば正常に削除できない可能性がある。)


# prometheusのインストール (同上)
