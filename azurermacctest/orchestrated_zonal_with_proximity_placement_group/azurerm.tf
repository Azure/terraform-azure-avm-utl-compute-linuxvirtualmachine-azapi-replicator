resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-${random_integer.number.result}"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = local.admin_password
  disable_password_authentication = false

  proximity_placement_group_id = azurerm_proximity_placement_group.test.id

  network_interface_ids = [
    azurerm_network_interface.test.id,
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
