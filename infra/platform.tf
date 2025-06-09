# Creating key vault 
resource "azurerm_key_vault" "booking_keyvault" {
  name                       = var.keyvault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.platform_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 10
  purge_protection_enabled   = false
  tags                       = var.tags
  enable_rbac_authorization  = true
}

# Key vault secrets
resource "azurerm_key_vault_secret" "mysql_username" {
  name         = "mysql-username"
  key_vault_id = azurerm_key_vault.booking_keyvault.id
  value        = var.mysql_username
}
resource "azurerm_key_vault_secret" "mysql_password" {
  name         = "mysql-password"
  key_vault_id = azurerm_key_vault.booking_keyvault.id
  value        = var.mysql_password
}

data "azurerm_key_vault_secret" "secrets" {
  for_each     = local.secret_env_map
  name         = each.key
  key_vault_id = azurerm_key_vault.booking_keyvault.id
}
# MySQL DB
resource "azurerm_mysql_flexible_server" "booking_db" {
  name                   = var.mysqldb_name
  resource_group_name    = azurerm_resource_group.platform_rg.name
  location               = var.location
  administrator_login    = azurerm_key_vault_secret.mysql_username.value
  administrator_password = azurerm_key_vault_secret.mysql_password.value
  sku_name               = var.mysqldb_sku
  # private_dns_zone_id          = azurerm_private_dns_zone.mysql_private_dns_zone.id
  # delegated_subnet_id          = azurerm_subnet.db_subnet.id
  #public_network_access        = "Enabled"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  tags                         = var.tags

  storage {
    io_scaling_enabled = true
    auto_grow_enabled  = true
    size_gb            = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_dns_link001, azurerm_private_dns_zone_virtual_network_link.mysql_dns_link002]
}

# Firewall rules for DB
resource "azurerm_mysql_flexible_server_firewall_rule" "alexip_db_access" {
  name                = "ClientIPAddress_AlexFontys"
  resource_group_name = azurerm_resource_group.platform_rg.name
  server_name         = azurerm_mysql_flexible_server.booking_db.name
  start_ip_address    = "145.93.124.167"
  end_ip_address      = "145.93.124.167"
}
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.platform_rg.name
  server_name         = azurerm_mysql_flexible_server.booking_db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
resource "azurerm_container_registry" "fonteyn_acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.platform_rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "booking_logs" {
  name                = var.logs_name
  location            = var.location
  resource_group_name = azurerm_resource_group.platform_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}