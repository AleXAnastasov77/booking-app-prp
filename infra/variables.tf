variable tags {
    description = "Tags to apply to all resources"
    type        = map(string)
    default     = {
    environment = "Production"
    owner  = "Aleks Anastasov"
    region = "North Europe"
  }
}