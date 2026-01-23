# Test Case Extraction and Conversion Summary

## Test Case: imageFromImage

### Part 1: Extract Test Case - COMPLETED ✅

**Source Location:** 
- Method: imageFromImage in linux_virtual_machine_resource_images_test.go
- GitHub URL: https://raw.githubusercontent.com/hashicorp/terraform-provider-azurerm/refs/heads/main/internal/services/compute/linux_virtual_machine_resource_images_test.go

**Directory Created:** zurermacctest/image_from_image

**Files Generated:**
1. **main.tf** (5,304 bytes)
   - Contains complete Terraform configuration with all providers
   - Includes terraform block with required_providers (azurerm ~> 4.0, azapi ~> 2.0, random ~> 3.0)
   - Single random_string resource (random_string.name)
   - Single random_integer resource (random_integer.number, min=100000, max=999999)
   - All infrastructure resources from nested templates expanded inline:
     * azurerm_resource_group.test
     * azurerm_virtual_network.test
     * azurerm_subnet.test
     * azurerm_public_ip.test
     * azurerm_network_interface.public (for source VM)
     * azurerm_network_interface.test (for test VM)
     * azurerm_linux_virtual_machine.source (source VM to create image from)
     * azurerm_image.test (captured from source VM)
   - Target VM resource removed (moved to azurerm.tf)
   - All placeholders converted:
     * data.RandomInteger → random_integer.number.result
     * data.RandomString → random_string.name.result  
     * data.Locations.Primary → "eastus"

### Part 2: Convert to AzAPI Module - COMPLETED ✅

**Files Generated:**

2. **azurerm.tf** (813 bytes)
   - Original azurerm_linux_virtual_machine.test resource extracted verbatim
   - Configuration showcases: source_image_id usage with custom image

3. **azapi.tf.bak** (2,433 bytes)
   - Module call to root module (source = "../..")
   - Module arguments:
     * name, resource_group_name, resource_group_id, location, size
     * admin_username, admin_password (with admin_password_version = 1)
     * disable_password_authentication = false
     * source_image_id = azurerm_image.test.id
     * network_interface_ids (list)
     * admin_ssh_key (converted to set of objects using toset())
     * os_disk (object with caching and storage_account_type)
   - azapi_resource.this with complete module output consumption
   - Dynamic identity block (for_each based on module output)
   - Dynamic timeouts block (for_each based on module output)

4. **moved.tf.bak** (87 bytes)
   - State migration block: azurerm_linux_virtual_machine.test → azapi_resource.this

### Key Test Scenario

This test case validates creating a Linux VM from a custom Azure image:
1. Creates source VM with Ubuntu 22.04 LTS
2. Captures image from source VM (azurerm_image)
3. Creates target VM using source_image_id pointing to captured image
4. Tests password authentication alongside SSH key
5. Demonstrates image capture and reuse workflow

### Module Configuration Highlights

- **Ephemeral field handling:** admin_password uses admin_password_version = 1
- **Set conversion:** admin_ssh_key converted from block to set of objects with toset()
- **Resource dependencies:** Proper dependency chain through source VM → image → target VM
- **Authentication:** Mixed auth with both password (admin_password) and SSH key
- **Image source:** Uses source_image_id instead of source_image_reference

### Validation Status

- [x] Part 1 complete: Extracted test case to standalone Terraform config
- [x] Part 2 complete: Converted to AzAPI module with azapi_resource
- [x] All placeholders transformed correctly
- [x] Single random resources created and reused
- [x] Module arguments mapped to variables.tf structure
- [x] Ephemeral admin_password handled with version tracking
- [x] Moved block configured correctly
- [x] No post_creation or post_update resources (none defined in migrate_outputs.tf)

### Next Steps

1. Execute 	erraform init in azurermacctest/image_from_image/
2. Test with azurerm.tf to validate baseline
3. Rename azapi.tf.bak → azapi.tf and moved.tf.bak → moved.tf
4. Remove azurerm.tf
5. Test migration scenario with 	erraform plan and 	erraform apply
6. Validate state migration and resource functionality

---
Generated: 2025-12-25
Test Case Status: Ready for Testing
