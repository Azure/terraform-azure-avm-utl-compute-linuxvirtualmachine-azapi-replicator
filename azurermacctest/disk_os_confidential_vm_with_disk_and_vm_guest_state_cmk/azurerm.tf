resource "azurerm_linux_virtual_machine" "test" {
  name                = "acctestVM-${random_integer.number.result}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_DC2as_v5"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = local.first_public_key
  }

  os_disk {
    caching                          = "ReadWrite"
    storage_account_type             = "Standard_LRS"
    security_encryption_type         = "DiskWithVMGuestState"
    secure_vm_disk_encryption_set_id = azurerm_disk_encryption_set.test.id
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-confidential-vm-jammy"
    sku       = "22_04-lts-cvm"
    version   = "latest"
  }

  vtpm_enabled        = true
  secure_boot_enabled = true

  depends_on = [
    azurerm_key_vault_access_policy.disk-encryption,
  ]
}
