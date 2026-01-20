terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.54.0"
    }

  }
  backend "azurerm" {
    resource_group_name  = "rg-app-prod"
    storage_account_name = "stcglqzse0k9"
    container_name       = "tfstate"
    key                  = "devops-prod"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "abcc12e8-46f6-4fb0-ae1f-86a92dafdaa7"
}
