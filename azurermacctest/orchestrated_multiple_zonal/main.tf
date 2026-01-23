terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azapi" {}

provider "random" {}

resource "random_string" "name" {
  length  = 8
  special = false
  upper   = false
}

resource "random_integer" "number" {
  min = 100000
  max = 999999
}

locals {
  vm_name = "acctestvm${random_string.name.result}"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-${random_integer.number.result}"
  location = "eastus"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-${random_integer.number.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "test" {
  name                = "acctestVMO-${random_integer.number.result}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  platform_fault_domain_count = 1

  zones = ["1"]

  tags = {
    ENV = "Test"
  }
}

resource "azurerm_network_interface" "first" {
  name                = "acctestnic1-${random_integer.number.result}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "second" {
  name                = "acctestnic2-${random_integer.number.result}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "another" {
  name                            = "acctestVM2-${random_integer.number.result}"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.second.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  virtual_machine_scale_set_id = azurerm_orchestrated_virtual_machine_scale_set.test.id
  zone                         = tolist(azurerm_orchestrated_virtual_machine_scale_set.test.zones)[0]
}
