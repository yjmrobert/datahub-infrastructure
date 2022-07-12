terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "project-rg" {
  name     = "${var.prefix}-${var.environment}-${var.project-acronym}-rg"
  location = var.location

  tags = {
    environment = "${var.environment}"
    project     = "${var.project-acronym}"
  }
}