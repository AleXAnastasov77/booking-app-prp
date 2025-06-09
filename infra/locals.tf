locals {
  backend_image = var.backend_image != "" ? var.backend_image : try(data.azurerm_container_app.api_current.template[0].container[0].image, null)
  frontend_image = var.frontend_image != "" ? var.frontend_image : data.azurerm_container_app.frontend_current.template[0].container[0].image
  admin_image    = var.admin_image != "" ? var.admin_image : data.azurerm_container_app.admin_current.template[0].container[0].image
}

locals {
  secret_env_map = {
    "clientid"          = "client-id"
    "clientsecret"      = "client-secret"
    "authority"         = "authority"
    "apikey"            = "api-key"
    "secretkey"         = "secret-key"
    "dbusernamesecret"  = "db-username"
    "dbpasswordsecret"  = "db-password"
  }

  secret_env_var_map = {
    "clientid"          = "CLIENT_ID"
    "clientsecret"      = "CLIENT_SECRET"
    "authority"         = "AUTHORITY"
    "apikey"            = "API_KEY"
    "secretkey"         = "SECRET_KEY"
    "dbusernamesecret"  = "DB_USERNAME_SECRET"
    "dbpasswordsecret"  = "DB_PASSWORD_SECRET"
  }
}