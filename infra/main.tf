terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
  }
  backend "azurerm" {
    use_oidc = true
    use_azuread_auth = true
    storage_account_name = "tfstatefonteyn"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"

  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "state-demo-secure" {
  name     = "state-demoo"
  location = "northeurope"
}