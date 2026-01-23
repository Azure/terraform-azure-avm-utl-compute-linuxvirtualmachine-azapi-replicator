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

resource "random_integer" "number" {
  min = 100000
  max = 999999
}

resource "random_string" "name" {
  length  = 8
  special = false
  upper   = false
}

locals {
  first_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9ddAwoR0XBoT9kixLX6atgX9dovt9fpR1HO/R9jYwYnuB+SZ845KSqat+U0m6oagZhpsfcEEwjGGjQz6Z1rB6mvffsKq6i74cmm0jO564nBnZQeh31q3sFNs+XdrDtFmnYRqdPHhhr1sw0C/rxbiaE6nYZWRfHW//81nEePKMpjiN8JsrYQNbzEpz8QOBSquwBmXO+LVx//zAbY4jGTa4hjGeNzIgMJZ8Jk/11XbcxSK1PK43BrejHg6kctmEkYvMH/o12RfAeB8okGCRW3scwOozxVrHwxaPgEf03jig+Ag9V+GXNBabL5AWtxcuPN63rUfaAXEIXTHmndwVOxlpLrUf5ox1+ddGyWbLMXzd7akPioof5MNJMq/yuFGC5dY0Z6/+yGRNtShQesVo/czhKEPGIcsIi5gnKdfDB4i9ay2yz8ystnW6jbabcyqejk1Qc61wapaFdhUHL0iD/GW/5ZujDs5C3BT7EIgKLIfAaAx5TBEJyE1KQ/GEOifB8ztDl/gp99o+i2HKABtmYv12y4JVlEUkRckeLrw6luEbColHshsQcQGfudGFFgdEdcgBrV4Ch7IkLxVYQl3pegzZiirMPnRKh10r/Hrg6uYxn7sLeTJoD5VOKmqmeK4kFXsZMVtA6/SnxQtUKkKlfLBwBSDrrdgLjBV+KOndiwC7Q=="
  second_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0/NDMj2wG6bSa6jbn6E3LYlUsYiWMp1CQ2sGAijPALW6OrSu30lz7nKpoh8Qdw7/A4nAJgweI5Oiiw5/BOaGENM70Go+VM8LQMSxJ4S7/8MIJEZQp5HcJZ7XDTcEwruknrd8mllEfGyFzPvJOx6QAQocFhXBW6+AlhM3gn/dvV5vdrO8ihjET2GoDUqXPYC57ZuY+/Fz6W3KV8V97BvNUhpY5yQrP5VpnyvvXNFQtzDfClTvZFPuoHQi3/KYPi6O0FSD74vo8JOBZZY09boInPejkm9fvHQqfh0bnN7B6XJoUwC1Qprrx+XIy7ust5AEn5XL7d4lOvcR14MxDDKEp you@me.com"
  vm_name           = "acctestsourcevm-${random_integer.number.result}"
  admin_username    = "testadmin${random_integer.number.result}"
  admin_password    = "Password1234!${random_integer.number.result}"
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

resource "azurerm_public_ip" "test" {
  name                = "acctpip-${random_integer.number.result}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  domain_name_label   = local.vm_name
  sku                 = "Basic"
}

resource "azurerm_network_interface" "public" {
  name                = "acctnicsource-${random_integer.number.result}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfigurationsource"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-${random_integer.number.result}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


