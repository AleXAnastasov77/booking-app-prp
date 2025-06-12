# Private DNS Zone for the database and key vault
resource "azurerm_private_dns_zone" "mysql_private_dns_zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.platform_rg.name
}
resource "azurerm_private_dns_zone" "keyvault_private_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.platform_rg.name
}
# ubuntu vnet id

data "azurerm_virtual_network" "ubuntu_vnet" {
  name                = "ubuntu-server-vnet"
  resource_group_name = "rg-accounting-prod-northeu-001"
}

# Connecting DNS zones to the hub and spoke virtual networks
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link001" {
  name                  = "dnslink-northeu-001"
  resource_group_name   = azurerm_resource_group.platform_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.booking_hub_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link002" {
  name                  = "dnslink-northeu-002"
  resource_group_name   = azurerm_resource_group.platform_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.booking_spoke_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link003" {
  name                  = "dnslink-northeu-003"
  resource_group_name   = azurerm_resource_group.platform_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.ubuntu_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_dns_link001" {
  name                  = "dnslink-northeu-003"
  resource_group_name   = azurerm_resource_group.platform_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.booking_hub_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_dns_link002" {
  name                  = "dnslink-northeu-004"
  resource_group_name   = azurerm_resource_group.platform_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.booking_spoke_vnet.id
}