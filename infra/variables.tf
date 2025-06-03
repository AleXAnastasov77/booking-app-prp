variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "Production"
    owner       = "Aleks Anastasov"
    region      = "North Europe"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_name_platform" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Name of the location used for the resources"
  type        = string
  default     = "West Europe"
}

variable "spoke_vnet_name" {
  description = "Name of the spoke virtual network"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "mysqldb_name" {
  description = "Name of the MySQL Flexible Database"
  type        = string
}

variable "mysqldb_sku" {
  description = "SKU name of the MySQL Flexible Database"
  type        = string
}

variable "keyvault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "mysql_username" {
  description = "Username of the MySQL"
  type        = string
}
variable "mysql_password" {
  description = "Password of the MySQL"
  type        = string
}