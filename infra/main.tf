
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
  tags                         = var.tags

  dynamic "secret" {
    for_each = local.secret_env_map
    content {
      name                = secret.value
      key_vault_secret_id = data.azurerm_key_vault_secret.secrets[secret.key].id
      identity            = azurerm_user_assigned_identity.booking_identity.id
    }
  }

  template {
    container {
      name   = "fonteynapi"
      image  = "${azurerm_container_registry.fonteyn_acr.login_server}/fonteyn-booking-app-api:1.0"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.booking_identity.client_id
      }
      dynamic "env" {
        for_each = local.secret_env_var_map
        content {
          name        = env.value
          secret_name = local.secret_env_map[env.key]
        }
      }
    }
    min_replicas = 1
    max_replicas = 3
    http_scale_rule {
      name = "http-scaling-rule"
      concurrent_requests = 50
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.booking_identity.id]
  }

  ingress {
    external_enabled = false
    target_port      = 5006

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.fonteyn_acr.login_server
    identity = azurerm_user_assigned_identity.booking_identity.id
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.github_acr_pull
  ]
}



resource "azurerm_container_app" "booking_frontend" {
  name                         = var.container_frontend_name
  container_app_environment_id = azurerm_container_app_environment.booking_env.id
  resource_group_name          = azurerm_resource_group.booking_rg.name
  revision_mode                = "Single"
  tags                         = var.tags
  dynamic "secret" {
    for_each = local.secret_env_map
    content {
      name                = secret.value
      key_vault_secret_id = data.azurerm_key_vault_secret.secrets[secret.key].id
      identity            = azurerm_user_assigned_identity.booking_identity.id
    }
  }

  template {
    container {
      name = "fonteynfrontend"
      #image  = local.frontend_image
      # This image is only used for initial deployment.
      # Actual version is managed by the application pipeline via Azure CLI after build.
      image  = "${azurerm_container_registry.fonteyn_acr.login_server}/fonteyn-booking-app-frontend:1.0"
      cpu    = 0.25
      memory = "0.5Gi"
      dynamic "env" {
        for_each = local.secret_env_var_map
        content {
          name        = env.value
          secret_name = local.secret_env_map[env.key]
        }
      }
      env {
        name  = "API_URL"
        value = "https://${azurerm_container_app.booking_api.latest_revision_fqdn}"
      }
    }
    min_replicas = 1
    max_replicas = 3
    http_scale_rule {
      name = "http-scaling-rule"
      concurrent_requests = 50
      
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.booking_identity.id]
  }

  ingress {
    external_enabled = true
    target_port      = 5008
    traffic_weight {
      percentage      = 100
      latest_revision = true
      revision_suffix = null
    }
  }

  registry {
    server   = azurerm_container_registry.fonteyn_acr.login_server
    identity = azurerm_user_assigned_identity.booking_identity.id
  }
  lifecycle {
  ignore_changes = [
    template[0].container[0].image
  ]
  }

  depends_on = [azurerm_role_assignment.acr_pull, azurerm_role_assignment.github_acr_pull]
}

resource "azurerm_container_app" "booking_admin" {
  name                         = var.container_admin_name
  container_app_environment_id = azurerm_container_app_environment.booking_env.id
  resource_group_name          = azurerm_resource_group.booking_rg.name
  revision_mode                = "Single"
  tags                         = var.tags
  dynamic "secret" {
    for_each = local.secret_env_map
    content {
      name                = secret.value
      key_vault_secret_id = data.azurerm_key_vault_secret.secrets[secret.key].id
      identity            = azurerm_user_assigned_identity.booking_identity.id
    }
  }
  template {
    container {
      name = "fonteynadmin"
      #image  = local.backend_image
      # This image is only used for initial deployment.
      # Actual version is managed by the application pipeline via Azure CLI after build.
      image  = "${azurerm_container_registry.fonteyn_acr.login_server}/fonteyn-booking-app-adminfrontend:1.0" 
      cpu    = 0.25
      memory = "0.5Gi"
      dynamic "env" {
        for_each = local.secret_env_var_map
        content {
          name        = env.value
          secret_name = local.secret_env_map[env.key]
        }
      }
      env {
          name  = "API_URL"
          value = "https://${azurerm_container_app.booking_api.latest_revision_fqdn}"
        }
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.booking_identity.id]
  }

  ingress {
    external_enabled = true
    target_port      = 5007
    traffic_weight {
      percentage      = 100
      latest_revision = true
      revision_suffix = null
    }
  }

  registry {
    server   = azurerm_container_registry.fonteyn_acr.login_server
    identity = azurerm_user_assigned_identity.booking_identity.id
  }

  lifecycle {
  ignore_changes = [
    template[0].container[0].image
  ]
  }

  depends_on = [azurerm_role_assignment.acr_pull, azurerm_role_assignment.github_acr_pull]
}


data "azurerm_container_app" "api_current" {
  name                = var.container_api_name
  resource_group_name = azurerm_resource_group.booking_rg.name
}

data "azurerm_container_app" "frontend_current" {
  name                = var.container_frontend_name
  resource_group_name = azurerm_resource_group.booking_rg.name
}

data "azurerm_container_app" "admin_current" {
  name                = var.container_admin_name
  resource_group_name = azurerm_resource_group.booking_rg.name
}


