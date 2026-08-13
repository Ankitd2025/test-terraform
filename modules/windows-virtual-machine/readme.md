# Azure Windows Virtual Machine Module

This module deploys a private Windows virtual machine with a NIC-level NSG, system-assigned managed identity, trusted launch controls, host encryption, optional CMK disk encryption, Azure Monitor Agent, and Guest Configuration.

By default no public IP is attached and inbound VNet traffic is denied unless explicit `allowed_inbound_rules` are supplied.
