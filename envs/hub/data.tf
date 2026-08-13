# Client configuration data source for Azure Resource Manager
data "azurerm_client_config" "azurerm_client_config" {}

# Azure Virtual Network data source for the Operations Virtual Network
data "azurerm_virtual_network" "operations_vnet" {
  name                = var.ops_vnet_name
  resource_group_name = var.ops_resource_group_name
}
