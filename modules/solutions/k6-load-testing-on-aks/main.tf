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
module "vent" {
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

# acr 作成

# aks クラスター作成

# public IP Address Prefix 作成

# nat gateway 作成

# k6-operatorのインストール (helmでインストールしたものもtfstateで管理するのか微妙？頻繁に実行基盤が削除されるのであれば、ｄelete時にhelmでインストールしたものの状態が変更していれば正常に削除できない可能性がある。)

# prometheusのインストール (同上)
