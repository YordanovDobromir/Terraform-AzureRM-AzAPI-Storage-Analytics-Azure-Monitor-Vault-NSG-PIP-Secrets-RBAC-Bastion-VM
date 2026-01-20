resource "azapi_resource" "rg" {
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
  name      = "rg-${var.application_name}-${var.environment_name}"
  location  = var.primary_region
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
}

data "azapi_client_config" "current" {}

resource "azapi_resource" "pip" {
  type      = "Microsoft.Network/publicIPAddresses@2025-03-01"
  name      = "pip-${var.application_name}-${var.environment_name}"
  parent_id = azapi_resource.rg.id
  location  = azapi_resource.rg.location

  body = {
    properties = {
      publicIPAddressVersion   = "IPv4"
      publicIPAllocationMethod = "Static"
    }
    sku = {
      name = "Standard"
    }
  }
}

data "azapi_resource" "network_rg" {
  name      = "rg-network-${var.environment_name}"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}

data "azapi_resource" "vnet" {
  name      = "vnet-network-${var.environment_name}"
  parent_id = data.azapi_resource.network_rg.id
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
}

data "azapi_resource" "subnet_b" {
  name      = "snet-b"
  parent_id = data.azapi_resource.vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
}

resource "azapi_resource" "networkInterface" {
  type      = "Microsoft.Network/networkInterfaces@2022-07-01"
  parent_id = azapi_resource.rg.id
  name      = "nic-${var.application_name}-${var.environment_name}-vm1"
  location  = azapi_resource.rg.location
  body = {
    properties = {
      ipConfigurations = [
        {
          name = "public"
          properties = {
            privateIPAddressVersion   = "IPv4"
            privateIPAllocationMethod = "Dynamic"
            publicIPAddress = {
              id = azapi_resource.pip.id
            }
            subnet = {
              id = data.azapi_resource.subnet_b.id
            }
          }
        },
      ]
    }
  }

}

data "azapi_resource" "keyvault_rg" {
  name      = "rg-devops-${var.environment_name}"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}

data "azapi_resource" "keyvault" {
  name      = "kv-devops-dev-scvq3d"
  parent_id = data.azapi_resource.keyvault_rg.id
  type      = "Microsoft.KeyVault/vaults@2025-05-01"
}

resource "tls_private_key" "vm1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azapi_resource" "azapi-vm1ssh-public" {
  type                      = "Microsoft.KeyVault/vaults/secrets@2025-05-01"
  name                      = "azapi-vm1ssh-public"
  parent_id                 = data.azapi_resource.keyvault.id
  schema_validation_enabled = false

  body = {
    properties = {
      value = tls_private_key.vm1.public_key_openssh
    }
  }
  lifecycle {
    ignore_changes = [location]
  }
}

resource "azapi_resource" "azapi-vm1ssh-private" {
  type                      = "Microsoft.KeyVault/vaults/secrets@2025-05-01"
  name                      = "azapi-vm1ssh-private"
  parent_id                 = data.azapi_resource.keyvault.id
  schema_validation_enabled = false

  body = {
    properties = {
      value = tls_private_key.vm1.private_key_pem
    }
  }
  lifecycle {
    ignore_changes = [location]
  }
}

resource "azapi_resource" "vm1" {
  type      = "Microsoft.Compute/virtualMachines@2025-04-01"
  name      = "vm1${var.application_name}${var.environment_name}"
  parent_id = azapi_resource.rg.id
  identity {
    type = "SystemAssigned"
  }
  location = azapi_resource.rg.location
  body = {
    properties = {
      hardwareProfile = {
        vmSize = "Standard_B1s"
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.networkInterface.id
          },
        ]
      }
      osProfile = {
        adminUsername = "adminuser"
        computerName  = "vm1${var.application_name}${var.environment_name}"
        linuxConfiguration = {
          ssh = {
            publicKeys = [
              {
                keyData = tls_private_key.vm1.public_key_openssh
                path    = "/home/adminuser/.ssh/authorized_keys"
              }
            ]
          }
        }
      }
      storageProfile = {
        imageReference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }
        dataDisks = [
          {
            caching      = "ReadWrite"
            createOption = "Empty"
            lun          = 1
            diskSizeGB   = 1
            managedDisk = {
              storageAccountType = "Standard_LRS"
            }
          }
        ]
      }
    }
  }
}
