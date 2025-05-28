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

resource "azurerm_virtual_network" "booking_hub_vnet" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.booking_rg.location
  resource_group_name = var.resource_group_name_platform
  address_space       = ["10.0.0.0/16"]
  tags = var.tags

  subnet { # Subnet for mysql database
    name             = "subnet-db"
    address_prefixes = ["10.0.1.0/24"]
    #default_outbound_access_enabled = false
    delegation {
      name = "db-delegation"
      service_delegation {
        name = "Microsoft.DBforMySQL/flexibleServers"
      }
    }
  }
  
  subnet { # Subnet for keyvault
    name             = "subnet-keyvault"
    address_prefixes = ["10.0.2.0/24"]
    #default_outbound_access_enabled = false
  }
}

resource "azurerm_virtual_network" "booking_spoke_vnet" {
  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.booking_rg.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.1.0.0/16"]
  tags = var.tags

  
  subnet { # Subnet for container apps environment
    name             = "subnet-containerenvironment"
    address_prefixes = ["10.1.1.0/24"]
    #default_outbound_access_enabled = false
  }
}

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

# resource "azurerm_private_dns_zone" "fonteyn_private_dns_zone" {
#   name                = "fonteyn.private"
#   resource_group_name = azurerm_resource_group.booking_rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "fonteyn_private_dns_zone_link1" {
#   name                  = "dnslink-northeu-001"
#   resource_group_name   = azurerm_resource_group.booking_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.fonteyn_private_dns_zone.name
#   virtual_network_id    = azurerm_virtual_network.booking_hub_vnet.id
# }
# resource "azurerm_private_dns_zone_virtual_network_link" "fonteyn_private_dns_zone_link2" {
#   name                  = "dnslink-northeu-002"
#   resource_group_name   = azurerm_resource_group.booking_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.fonteyn_private_dns_zone.name
#   virtual_network_id    = azurerm_virtual_network.booking_spoke_vnet.id
# }
