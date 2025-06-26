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
  private_dns_zone_id          = azurerm_private_dns_zone.mysql_private_dns_zone.id
  delegated_subnet_id          = azurerm_subnet.db_subnet.id
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

# Front Door
resource "azurerm_cdn_frontdoor_profile" "booking_frontdoor" {
  name                = var.frontdoor_name
  resource_group_name = azurerm_resource_group.platform_rg.name
  sku_name            = "Standard_AzureFrontDoor"
  tags = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor_endpoint" {
  name                     = local.frontdoorendpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.booking_frontdoor.id
}
resource "azurerm_cdn_frontdoor_origin_group" "frontdoor_admin_og" {
  name                     = var.origin_admin_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.booking_frontdoor.id
  session_affinity_enabled = true
  load_balancing {}
}
resource "azurerm_cdn_frontdoor_origin" "frontdoor_admin_origin" {
  name                          = "admin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_admin_og.id

  enabled                        = true
  host_name                      = azurerm_container_app.booking_admin.latest_revision_fqdn
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_container_app.booking_admin.latest_revision_fqdn
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "frontdoor_admin_route" {
  name                          = "admin"
  enabled = true
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_admin_og.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.frontdoor_admin_origin.id]
  cdn_frontdoor_origin_path = "/"
  cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.frontdoor_ruleset.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/admin", "/admin/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}
resource "azurerm_cdn_frontdoor_origin_group" "frontdoor_frontend_og" {
  name                     = var.origin_frontend_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.booking_frontdoor.id
  session_affinity_enabled = true
  load_balancing {}
}
resource "azurerm_cdn_frontdoor_origin" "frontdoor_frontend_origin" {
  name                          = "frontend"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_frontend_og.id

  enabled                        = true
  host_name                      = azurerm_container_app.booking_frontend.latest_revision_fqdn
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_container_app.booking_frontend.latest_revision_fqdn
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "frontdoor_frontend_route" {
  name                          = "frontend"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_frontend_og.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.frontdoor_frontend_origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/", "/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}

resource "azurerm_cdn_frontdoor_rule_set" "frontdoor_ruleset" {
  name                     = "adminredirect"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.booking_frontdoor.id
}

resource "azurerm_cdn_frontdoor_rule" "frontdoor_rule" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.frontdoor_admin_og, azurerm_cdn_frontdoor_origin.frontdoor_admin_origin]
  
  name = "adminredirect"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.frontdoor_ruleset.id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {
    url_rewrite_action {
      source_pattern = "/"
      destination = "/"
      preserve_unmatched_path = true
    }
  }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "frontdoor_firewall_policy" {
  name = "WAFfFIREWALLpolicy"
  resource_group_name = azurerm_resource_group.platform_rg.name
  sku_name = azurerm_cdn_frontdoor_profile.booking_frontdoor.sku_name
  enabled = true
  mode = "Prevention"
}
resource "azurerm_cdn_frontdoor_security_policy" "frontdoor_security_policy" {
  name                     = "WAFpolicy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.booking_frontdoor.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.frontdoor_firewall_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}