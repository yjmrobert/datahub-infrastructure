terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "${var.prefix}-${var.environment}-tfstate"
  location = "${var.location}"

  tags = {
    environment = "${var.environment}"
    project = "DataHub State"
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}


# Save the storage account details to a file for later reference in scripts
resource "local_file" "output" {
  content = <<EOT
  storage_account_name = ${azurerm_storage_account.tfstate.name}
  resource_group_name = ${azurerm_storage_account.tfstate.resource_group_name}
  container_name = ${azurerm_storage_container.tfstate.name}
  EOT
  filename = "${path.module}/storage_account.values"
}