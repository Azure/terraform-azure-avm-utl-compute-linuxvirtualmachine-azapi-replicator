resource "azurerm_linux_virtual_machine" "test" {
  name                = "acctestVMimport-${random_integer.number.result}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_F2"

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_managed_disk_id = data.azurerm_managed_disks.test.disk.0.id

  os_disk {
    caching      = "ReadWrite"
    disk_size_gb = 30
  }
}
