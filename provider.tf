provider "oci" {
  tenancy_ocid     = var.oci_tenancy
  user_ocid        = var.oci_user
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key
  region           = var.oci_region
}
provider "azurerm" {
  features {}
  subscription_id  = var.azure_subscription_id
  tenant_id        = var.azure_tenant_id
  client_id        = var.azure_client_id
  client_secret    = var.azure_client_secret
}
