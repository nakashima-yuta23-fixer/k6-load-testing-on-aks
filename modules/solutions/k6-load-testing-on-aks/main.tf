# ------------------------------------------------------------------------------
# Naming
# ------------------------------------------------------------------------------

module "nat_gateway_naming" {
  source = "../../utils/naming"

  resource_type = "nat_gateway"
  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  location      = var.location
}

module "public_ip_address_naming" {
  source = "../../utils/naming"

  resource_type = "public_ip_address"
  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  location      = var.location
}

# resource group 作成
module "resource_group" {
  source = "../../foundations/core_resource_group"

  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  location      = var.location

  # Enable optional governance features
  enable_delete_lock            = true
  enable_tag_inheritance_policy = true

  # Add custom tags to the resource group
  custom_tags = {
    "solution" = "k6-load-testing-on-aks"
  }
}

# vnet/subnet 作成
module "vnet" {
  source = "../../foundations/networking_vnet"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  customer_code       = var.customer_code
  role                = var.role
  environment         = var.environment

  vnet_address_space = var.vnet_address_space

  subnets = {
    "gateway-k8s" = {
      address_prefixes = var.snet_address_prefixes_gateway_k8s
    },
    "cluster-k8s" = {
      address_prefixes = var.snet_address_prefixes_cluster_k8s
    },
  }
}

# nsg 作成

# peering 作成 (prometheus でメトリックを Grafana にエクスポートするため)

# # acr 作成
# # TODO: foudationsモジュールから呼び出せるようにする。
# resource "azurerm_container_registry" "this" {
#   name                = "crk6testloadtestingdvje"
#   resource_group_name = module.resource_group.name
#   location            = module.resource_group.location
#   sku                 = "Standard"
#   admin_enabled       = false

#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# # aks クラスター作成
# # TODO: foudationsモジュールから呼び出せるようにする。
# resource "azurerm_kubernetes_cluster" "this" {
#   name                = "aks-load-testing-dv-je"
#   location            = module.resource_group.location
#   resource_group_name = module.resource_group.name
#   dns_prefix          = "aks-load-testing-dv-je-dns"

#   default_node_pool {
#     name                 = "npsystem"
#     node_count           = 2
#     vm_size              = "Standard_D8ls_v5"
#     auto_scaling_enabled = false
#     max_pods             = 110
#     os_disk_type         = "Managed"
#     os_sku               = "Ubuntu"
#     type                 = "VirtualMachineScaleSets"
#     upgrade_settings {
#       drain_timeout_in_minutes      = 0
#       max_surge                     = "10%"
#       node_soak_duration_in_minutes = 0
#     }
#     vnet_subnet_id = module.vnet.subnet_ids["cluster-k8s"]
#     zones          = [1]
#   }

#   api_server_access_profile {
#     authorized_ip_ranges = ["202.211.86.16/32"]
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   image_cleaner_enabled = false # 負荷試験実行基盤用のAKSは負荷試験が終わり次第クラスターを削除する予定のため

#   # 常に最新バージョンを使用するため、kubernetes_versionは指定せず常に最新バージョンでAKSを構築する。
#   # kubernetes_version = "x.x.x"

#   local_account_disabled = false

#   network_profile {
#     network_plugin      = "azure"
#     network_data_plane  = "azure"
#     network_plugin_mode = "overlay"
#   }

#   bootstrap_profile {
#     artifact_source = "Direct"
#   }

#   node_os_upgrade_channel = "None"

#   oidc_issuer_enabled               = false
#   open_service_mesh_enabled         = false
#   workload_identity_enabled         = false
#   role_based_access_control_enabled = true
#   sku_tier                          = "Standard"

#   storage_profile {
#     blob_driver_enabled         = true
#     disk_driver_enabled         = true
#     file_driver_enabled         = true
#     snapshot_controller_enabled = true
#   }

#   support_plan = "KubernetesOfficial"

#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# output "object_id_of_managed_id_for_aks" {
#   description = "Object ID of system-assigned managed identity for AKS cluster"
#   value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
# }

# nat gateway 作成
resource "azurerm_nat_gateway" "this" {
  name                    = module.nat_gateway_naming.kebab
  resource_group_name     = module.resource_group.name
  location                = var.location
  sku_name                = var.nat_gateway_sku_name
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout_in_minutes

  lifecycle {
    ignore_changes = [tags]
  }
}

# public IP Address 作成
resource "azurerm_public_ip" "public_ip" {
  count               = var.is_ip_address_prefix ? 0 : 1

  name                = module.public_ip_address_naming.kebab
  resource_group_name = module.resource_group.name
  location            = var.location

  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    ignore_changes = [tags]
  }
}

# public IP Address Prefix 作成
resource "azurerm_public_ip_prefix" "public_ip_prefix" {
  count               = var.is_ip_address_prefix ? 1 : 0

  name                = module.public_ip_address_naming.kebab
  resource_group_name = module.resource_group.name
  location            = var.location

  prefix_length       = 30
  sku                 = "Standard"

  lifecycle {
    ignore_changes = [tags]
  }
}

# nat gateway 作成
resource "azurerm_nat_gateway_public_ip_association" "public_ip_association" {
  count                = var.is_ip_address_prefix ? 0 : 1
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.public_ip[0].id
}

# 
resource "azurerm_nat_gateway_public_ip_prefix_association" "public_ip_prefix_association" {
  count               = var.is_ip_address_prefix ? 1 : 0

  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.public_ip_prefix[0].id
}

# subnetとnat gateway紐づけ
resource "azurerm_subnet_nat_gateway_association" "subnet_association" {
  subnet_id      = module.vnet.subnet_ids["cluster-k8s"]
  nat_gateway_id = azurerm_nat_gateway.this.id
}

# k6-operatorのインストール (helmでインストールしたものもtfstateで管理するのか微妙？頻繁に実行基盤が削除されるのであれば、ｄelete時にhelmでインストールしたものの状態が変更していれば正常に削除できない可能性がある。)


# prometheusのインストール (同上)
