variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "Production"
    owner       = "Aleks Anastasov"
    region      = "Sweden"
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
  default     = "swedencentral"
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

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "logs_name" {
  default = "Name of the log analytics workspace"
  type    = string
}

variable "containerenv_name" {
  default = "Name of the container app environment"
  type    = string
}

# container names
variable "container_api_name" {
  description = "The container app name of the api"
  type        = string
}
variable "container_frontend_name" {
  description = "The container app name of the frontend"
  type        = string
}
variable "container_admin_name" {
  description = "The container app name of the admin frontend"
  type        = string
}

# container images variables
variable "backend_image" {
  description = "The image name of the backend"
  type        = string
  default     = ""
}
variable "frontend_image" {
  description = "The image name of the frontend"
  type        = string
  default     = ""
}
variable "admin_image" {
  description = "The image name of the admin frontend"
  type        = string
  default     = ""
}
