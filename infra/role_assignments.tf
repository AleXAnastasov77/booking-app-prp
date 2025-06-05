# Giving terraform access to the key vault
resource "azurerm_role_assignment" "terraform_keyvault_access" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.booking_keyvault.id
}

resource "azurerm_role_assignment" "acr_push_permission" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.fonteyn_acr.id
}

resource "azurerm_user_assigned_identity" "booking_identity" {
  name                = "booking_identity"
  location            = var.location
  resource_group_name = azurerm_resource_group.booking_rg.name
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.booking_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.fonteyn_acr.id
}

resource "azurerm_role_assignment" "github_acr_pull" {
  scope                = azurerm_container_registry.fonteyn_acr.id
  role_definition_name = "AcrPull"
  principal_id         = "a7c2abb4-ca2b-4746-af52-bcf8467ca658"
}
