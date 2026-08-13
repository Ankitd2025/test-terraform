# Azure Application Gateway Module

This module deploys a WAF-enabled Azure Application Gateway with both public and private frontend IP configurations. The module owns its Standard static public IP, user-assigned managed identity, Key Vault RBAC for certificate access, default HTTP listeners, optional HTTPS listeners from a Key Vault certificate secret ID, WAF defaults, autoscale defaults, and diagnostic settings.

The intended environment-level input is the SKU name. Other operational defaults are kept inside the module to reduce tfvars noise.
