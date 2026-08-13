# Azure Application Insights CAF Module

This module creates Azure Application Insights using the repository CAF naming and tagging pattern. The module inherits the AzureRM provider configuration from the calling Terraform configuration.

## Naming

The default Application Insights name is generated as:

```text
appi-<eai_code>-<region_code>-<dpc_code>-<resource_env_suffix>-<application_insights_sequence>
```

## Outputs

| Name | Description |
| --- | --- |
| `application_insights_id` | The ID of Application Insights. |
| `application_insights_name` | The name of Application Insights. |
| `application_insights_app_id` | The App ID of Application Insights. |
| `application_insights_instrumentation_key` | The sensitive instrumentation key. |
| `application_insights_connection_string` | The sensitive connection string. |