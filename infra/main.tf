
data "azurerm_client_config" "current" {}


# data "azurerm_container_app" "frontend_current" {
#   name                = "booking-frontend"
#   resource_group_name = azurerm_resource_group.booking_rg.name
# }

# data "azurerm_container_app" "admin_current" {
#   name                = "booking-admin"
#   resource_group_name = azurerm_resource_group.booking_rg.name
# }

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
  name                       = "containerenv-booking-prod-sweden-001"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.booking_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.booking_logs.id
  infrastructure_subnet_id   = azurerm_subnet.containerapps_subnet.id
}

resource "azurerm_container_app" "booking_api" {
  name                         = var.container_api_name
  container_app_environment_id = azurerm_container_app_environment.booking_env.id
  resource_group_name          = azurerm_resource_group.booking_rg.name
  revision_mode                = "Single"
  tags = var.tags

  template {
    container {
      name   = "fonteynapi"
      image  = local.backend_image
      #image  = "${azurerm_container_registry.fonteyn_acr.login_server}/fonteyn-booking-app-api:1.0"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.booking_identity.id]
  }

  ingress {
    external_enabled = true
    target_port = 5006
    traffic_weight {
      percentage = 100
      latest_revision = true
      revision_suffix  = null
    }
  }

  registry {
    server               = azurerm_container_registry.fonteyn_acr.login_server
    identity             = azurerm_user_assigned_identity.booking_identity.id
  }

  depends_on = [azurerm_role_assignment.acr_pull, azurerm_role_assignment.github_acr_pull]
}

data "azurerm_container_app" "api_current" {
  name                = "booking-api"
  resource_group_name = azurerm_resource_group.booking_rg.name
}



