# Hub Vnet and subnets
resource "azurerm_virtual_network" "booking_hub_vnet" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.booking_rg.location
  resource_group_name = azurerm_resource_group.platform_rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}
resource "azurerm_subnet" "db_subnet" {
  name                 = "subnet-db"
  resource_group_name  = azurerm_resource_group.platform_rg.name
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
  resource_group_name  = azurerm_resource_group.platform_rg.name
  virtual_network_name = azurerm_virtual_network.booking_hub_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  # Can add a NSG later
  # Example: network_security_group_id = azurerm_network_security_group.my_nsg.id

  #default outbound access—only applies to container apps
}


# Spoke VNet and subnets
resource "azurerm_virtual_network" "booking_spoke_vnet" {
  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.booking_rg.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.1.0.0/16"]
  tags                = var.tags
}
resource "azurerm_subnet" "containerapps_subnet" {
  name                 = "subnet-containerenvironment"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.booking_spoke_vnet.name
  address_prefixes     = ["10.1.0.0/23"]
  # default_outbound_access_enabled = false
  service_endpoints = "Microsoft.KeyVault"
}



# Connecting the hub and spoke VNets
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.platform_rg.name
  virtual_network_name      = azurerm_virtual_network.booking_hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.booking_spoke_vnet.id
}
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.booking_spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.booking_hub_vnet.id
}