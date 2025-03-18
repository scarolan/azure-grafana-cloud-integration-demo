terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_mssql_server" "primary" {
  name                         = var.primary_database
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = var.primary_database_version
  administrator_login          = var.primary_database_admin
  administrator_login_password = var.primary_database_password
  minimum_tls_version         = "1.2"
  tags                        = var.tags
}

# Create a database within the SQL Server
resource "azurerm_mssql_database" "database" {
  name           = "${var.primary_database}-db"
  server_id      = azurerm_mssql_server.primary.id
  sku_name       = "Basic"  # Can be changed to: Standard, Premium, etc.
  tags           = var.tags
}

# Configure firewall rules
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.primary.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

