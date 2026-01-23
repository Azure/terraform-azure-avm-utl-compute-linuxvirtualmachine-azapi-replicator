resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-${random_integer.number.result}"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  disable_password_authentication = false
  admin_password                  = "Eung6ahthane2ied"
  source_image_id                 = azurerm_shared_image_version.test.id

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = local.first_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
