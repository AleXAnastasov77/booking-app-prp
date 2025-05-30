terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
  }
  backend "azurerm" {
    use_oidc = true
    use_azuread_auth = true
    storage_account_name = "tfstatefonteyn"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"

  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "booking_rg" {
  name = var.resource_group_name
  location = var.location
  tags = var.tags
}

# Hub Vnet and subnets
resource "azurerm_virtual_network" "booking_hub_vnet" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.booking_rg.location
  resource_group_name = var.resource_group_name_platform
  address_space       = ["10.0.0.0/16"]
  tags = var.tags
}
resource "azurerm_subnet" "db_subnet" {
  name                 = "subnet-db"
  resource_group_name  = var.resource_group_name_platform
  virtual_network_name = azurerm_virtual_network.booking_hub_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  #default_outbound_access_enabled = false
  delegation {
    name = "db-delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      }
    }
}
resource "azurerm_subnet" "keyvault_subnet" {
  name                 = "subnet-keyvault"
  resource_group_name  = var.resource_group_name_platform
  virtual_network_name = azurerm_virtual_network.booking_hub_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  # If you plan to add NSG or private endpoint, you can do it here later
  # Example: network_security_group_id = azurerm_network_security_group.my_nsg.id

  #default outbound access—only applies to container apps
}


# Spoke VNet and subnets
resource "azurerm_virtual_network" "booking_spoke_vnet" {
  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.booking_rg.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.1.0.0/16"]
  tags = var.tags
}
resource "azurerm_subnet" "containerapps_subnet" {
  name                 = "subnet-containerenvironment"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.booking_spoke_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
  # default_outbound_access_enabled = false  # Only used in azurerm_subnet for container apps
}



# Connecting the hub and spoke VNets
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name = "hub-to-spoke"
  resource_group_name = var.resource_group_name_platform
  virtual_network_name = azurerm_virtual_network.booking_hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.booking_spoke_vnet.id
}
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name = "spoke-to-hub"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.booking_spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.booking_hub_vnet.id
}


#Private DNS Zone for the database
resource "azurerm_private_dns_zone" "mysql_private_dns_zone" {
  name                = "fonteyn.mysql.database.azure.com"
  resource_group_name = var.resource_group_name_platform
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link001" {
  name                  = "dnslink-northeu-001"
  resource_group_name   = var.resource_group_name_platform
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.booking_hub_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link002" {
  name                  = "dnslink-northeu-002"
  resource_group_name   = var.resource_group_name_platform
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.booking_spoke_vnet.id
}

# resource "azurerm_mysql_flexible_server" "booking_db" {
#   name = var.mysqldb_name
#   resource_group_name = var.resource_group_name_platform
#   location = var.location
#   #administrator_login =
#   #administrator_password =
#   sku_name = var.mysqldb_sku
#   private_dns_zone_id = azurerm_private_dns_zone.mysql_private_dns_zone.id
#   delegated_subnet_id = azurerm_subnet.db_subnet.id

#   depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_dns_link001, azurerm_private_dns_zone_virtual_network_link.mysql_dns_link002]
# }