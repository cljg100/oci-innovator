# Configure the Providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
    oci = {
      source   = "hashicorp/oci"
      version  = "~> 4.50.0"
    }
  }
  required_version = ">=0.14.9"
}

resource "azurerm_resource_group" "azure-rg-apprh" {
  name     = "rg-apprh"
  location = "centralus"
#
  provisioner "local-exec" {
    command = "ansible-playbook config-app.yaml"
  }
}

# Create App Service Plan with Linux
resource "azurerm_app_service_plan" "azure-servplan-apprh" {
  name                = "${azurerm_resource_group.azure-rg-apprh.name}-plan"
  location            = "${azurerm_resource_group.azure-rg-apprh.location}"
  resource_group_name = "${azurerm_resource_group.azure-rg-apprh.name}"
  kind                = "Linux"

  sku {
    capacity = 1
    tier = "Free"
    size = "F1"
  }
  reserved = "true"

}

# Create Azure Web App for Containers in the App Service Plan
resource "azurerm_app_service" "dockerapprh" {
  name                = "${azurerm_resource_group.azure-rg-apprh.name}-dockerapp"
  location            = "${azurerm_resource_group.azure-rg-apprh.location}"
  resource_group_name = "${azurerm_resource_group.azure-rg-apprh.name}"
  app_service_plan_id = "${azurerm_app_service_plan.azure-servplan-apprh.id}"

#
# Configure Docker Image to be loaded on start
app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "https://index.docker.io"
    "DOCKER_REGISTRY_SERVER_USERNAME" = "<docker-userid>"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "<docker-userid-password>"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
  }
#
# Configure the access of the application (name + db login)
site_config {
    linux_fx_version = "COMPOSE||${filebase64("docker-compose.yml")}"
    always_on        = false
    use_32_bit_worker_process = true
  }
}
