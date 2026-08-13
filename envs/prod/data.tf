# Client configuration data source for Azure Resource Manager
data "azurerm_client_config" "azurerm_client_config" {}


# Azure Virtual Network data source for the Hub Virtual Network
data "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
  provider            = azurerm.hub
}

# Azure Virtual Network data source for the Operations Virtual Network
data "azurerm_virtual_network" "operations_vnet" {
  name                = var.ops_vnet_name
  resource_group_name = var.ops_resource_group_name
  provider            = azurerm.hub
}

# Azure Firewall data source for AKS user-defined routing egress
data "azurerm_firewall" "hub_firewall" {
  name                = var.hub_firewall_name
  resource_group_name = var.hub_resource_group_name
  provider            = azurerm.hub
}

# Azure Hub Bastion Subnet data source for Windows VM Bastion access
data "azurerm_subnet" "hub_bastion_subnet" {
  name                 = var.hub_bastion_subnet_name
  resource_group_name  = var.hub_resource_group_name
  virtual_network_name = data.azurerm_virtual_network.hub_vnet.name
  provider             = azurerm.hub
}
