resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}"
  location = var.primary_region
}

resource "random_string" "keyvault_suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azurerm_client_config" "tenant" {}

data "azurerm_log_analytics_workspace" "appRM-state" {
  name                = "log-appRM-state-${var.environment_name}"
  resource_group_name = "rg-appRM-state-${var.environment_name}"
}

resource "azurerm_key_vault" "main" {
  name                = "kv-${var.application_name}-${var.environment_name}-${random_string.keyvault_suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.tenant.tenant_id
  sku_name            = "standard"
}

resource "azurerm_role_assignment" "terraform_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.tenant.object_id
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name               = "diag-${var.application_name}-${var.environment_name}-${random_string.keyvault_suffix.result}"
  target_resource_id = azurerm_key_vault.main.id

  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.appRM-state.id

  enabled_log {
    category = "AuditEvent"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}
