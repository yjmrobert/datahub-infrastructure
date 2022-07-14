resource "random_string" "project_storage_azure_blob_resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "project_storage_azure_blob" {
  name                     = "${var.prefix}${var.environment}${var.project-acronym}${random_string.project_storage_azure_blob_resource_code.result}"
  resource_group_name      = "${azurerm_resource_group.project-rg.name}"
  location                 = "${azurerm_resource_group.project-rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "false"

  tags = {
    environment = "${var.environment}"
    project     = "${var.project-acronym}"
  }
}

resource "azurerm_storage_container" "datahub-container" {
  name                  = "${var.container-name}"
  storage_account_name  = azurerm_storage_account.project_storage_azure_blob.name
  container_access_type = "private"
}