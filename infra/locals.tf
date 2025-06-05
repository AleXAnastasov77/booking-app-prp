locals {
  backend_image  = var.backend_image != "" ? var.backend_image : data.azurerm_container_app.api_current.template[0].container[0].image
  frontend_image = var.frontend_image != "" ? var.frontend_image : data.azurerm_container_app.frontend_current.template[0].container[0].image
  admin_image    = var.admin_image != "" ? var.admin_image : data.azurerm_container_app.admin_current.template[0].container[0].image
}