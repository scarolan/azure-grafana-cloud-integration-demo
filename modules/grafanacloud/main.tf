#needed items for Grafana cloud integration as per https://grafana.com/docs/grafana-cloud/monitor-infrastructure/monitor-cloud-provider/azure/collect-azure-serverless/config-azure-metrics-serverless/

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
    grafana = {
        source = "grafana/grafana"
        version = ">= 3.18.0"
    }
  }
}

data "azurerm_client_config" "current" {}

# Create Azure AD Application for Grafana Cloud
#the following 4 blocks need application administrator permissions as per https://stackoverflow.com/questions/76423517/serviceprincipalsclient-baseclient-post-unexpected-status-403-with-odata-erro
# resource "azuread_application" "grafana" {
#   display_name = "grafana-cloud-azure-metrics-int"
#   owners       = [data.azurerm_client_config.current.object_id]
# }

# resource "azuread_service_principal" "grafana" {
#   client_id = azuread_application.grafana.client_id
#   use_existing = true
# }

# # Assign Monitoring Reader role to the Service Principal
# resource "azurerm_role_assignment" "grafana" {
#   scope                = "/subscriptions/${var.azure_subscription_id}"
#   role_definition_name = "Monitoring Reader"
#   principal_id         = azuread_service_principal.grafana.id
# }

# # Create Service Principal password
# resource "azuread_service_principal_password" "grafana" {
#   service_principal_id = azuread_service_principal.grafana.id
# }

# Get existing Azure AD Application
data "azuread_application" "grafana" {
  display_name = "grafana-cloud-azure-metric-integration"
}

# Configure provider for Azure integration
provider "grafana" {
  cloud_access_policy_token  = var.grafana_tf_access_policy_token
  cloud_provider_access_token = var.grafana_tf_access_policy_token
  cloud_provider_url         = "https://cloud-provider-api-${var.grafana_cloud_region}.grafana.net"
}


data "grafana_cloud_stack" "stack" {
  provider = grafana
  slug = var.org_slug
}

resource "grafana_cloud_provider_azure_credential" "azurecred" {
  stack_id = data.grafana_cloud_stack.stack.id
  name = "azure-credential"

  client_id = data.azuread_application.grafana.client_id
  client_secret = var.azure_app_registration_client_secret
  tenant_id = data.azurerm_client_config.current.tenant_id
}






