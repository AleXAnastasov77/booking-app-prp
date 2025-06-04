
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "booking_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
resource "azurerm_resource_group" "platform_rg" {
  name     = var.resource_group_name_platform
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_app_environment" "booking_env" {
  name                        = "containerenv-booking-prod-sweden-001"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.booking_rg.name
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.booking_logs.id
  infrastructure_subnet_id    = azurerm_subnet.containerapps_subnet.id
}






