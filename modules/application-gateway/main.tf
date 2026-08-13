resource "azurerm_public_ip" "azurerm_public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.public_ip_zones
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "azurerm_user_assigned_identity" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_application_gateway" "azurerm_application_gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  http2_enabled       = true
  tags                = var.tags

  sku {
    name = var.sku_name
    tier = var.sku_name
  }

  autoscale_configuration {
    min_capacity = var.autoscale_min_capacity
    max_capacity = var.autoscale_max_capacity
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.azurerm_user_assigned_identity.id]
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "public-frontend-ip"
    public_ip_address_id = azurerm_public_ip.azurerm_public_ip.id
  }

  frontend_ip_configuration {
    name                          = "private-frontend-ip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  dynamic "frontend_port" {
    for_each = var.key_vault_certificate_secret_id == null ? [] : [1]

    content {
      name = "https-port"
      port = 443
    }
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  dynamic "ssl_certificate" {
    for_each = var.key_vault_certificate_secret_id == null ? [] : [1]

    content {
      name                = "keyvault-ssl-certificate"
      key_vault_secret_id = var.key_vault_certificate_secret_id
    }
  }

  http_listener {
    name                           = "public-http-listener"
    frontend_ip_configuration_name = "public-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "private-http-listener"
    frontend_ip_configuration_name = "private-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  dynamic "http_listener" {
    for_each = var.key_vault_certificate_secret_id == null ? [] : [1]

    content {
      name                           = "public-https-listener"
      frontend_ip_configuration_name = "public-frontend-ip"
      frontend_port_name             = "https-port"
      protocol                       = "Https"
      ssl_certificate_name           = "keyvault-ssl-certificate"
    }
  }

  dynamic "http_listener" {
    for_each = var.key_vault_certificate_secret_id == null ? [] : [1]

    content {
      name                           = "private-https-listener"
      frontend_ip_configuration_name = "private-frontend-ip"
      frontend_port_name             = "https-port"
      protocol                       = "Https"
      ssl_certificate_name           = "keyvault-ssl-certificate"
    }
  }

  request_routing_rule {
    name                       = "public-http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "public-http-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-http-settings"
    priority                   = 100
  }

  request_routing_rule {
    name                       = "private-http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "private-http-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-http-settings"
    priority                   = 110
  }

  dynamic "request_routing_rule" {
    for_each = var.key_vault_certificate_secret_id == null ? [] : [1]

    content {
      name                       = "public-https-rule"
      rule_type                  = "Basic"
      http_listener_name         = "public-https-listener"
      backend_address_pool_name  = "default-backend-pool"
      backend_http_settings_name = "default-http-settings"
      priority                   = 120
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.key_vault_certificate_secret_id == null ? [] : [1]

    content {
      name                       = "private-https-rule"
      rule_type                  = "Basic"
      http_listener_name         = "private-https-listener"
      backend_address_pool_name  = "default-backend-pool"
      backend_http_settings_name = "default-http-settings"
      priority                   = 130
    }
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.azurerm_web_application_firewall_policy.id

  depends_on = [azurerm_web_application_firewall_policy.azurerm_web_application_firewall_policy]
}

resource "azurerm_web_application_firewall_policy" "azurerm_web_application_firewall_policy" {
  name                = "wafp-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  policy_settings {
    enabled                     = true
    mode                        = var.waf_firewall_mode   # or Detection
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

