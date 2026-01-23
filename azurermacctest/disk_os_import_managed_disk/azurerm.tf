resource "azurerm_linux_virtual_machine" "test" {
  name                = "acctestVMimport-${random_integer.number.result}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_E2bds_v5"

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_managed_disk_id = azurerm_managed_disk.test.id

  os_disk {
    caching = "ReadWrite"
  }
}
