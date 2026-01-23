# Test Case: network_multiple_template

## Part 1: Extraction - ✅ COMPLETED

The test case method `networkMultipleTemplate` has been successfully extracted from `linux_virtual_machine_resource_network_test.go`.

### Extracted Configuration
The extracted configuration in `main.tf` includes:
- Terraform and provider configurations (azurerm, azapi, random)
- Random resources for generating unique names
- SSH public key locals
- Azure Resource Group
- Azure Virtual Network
- Azure Subnet
- Two Azure Network Interfaces (first and second)

## Part 2: Conversion to AzAPI Module - ⚠️ NOT APPLICABLE

**IMPORTANT NOTE**: The `networkMultipleTemplate` method does NOT contain an `azurerm_linux_virtual_machine` resource. This is a helper method that only creates supporting infrastructure (network interfaces) for the actual VM test.

### Analysis
Looking at the provider test file structure:
- `networkMultipleTemplate(data)` - Creates network interfaces (extracted here)
- `networkMultiple(data)` - Creates the actual Linux VM using the network interfaces from `networkMultipleTemplate`
- `networkMultipleUpdated(data)` - Creates an updated version of the VM

### What was extracted:
```hcl
resource "azurerm_network_interface" "first" { ... }
resource "azurerm_network_interface" "second" { ... }
```

### What would need to be converted (NOT in this template):
```hcl
resource "azurerm_linux_virtual_machine" "test" { ... }
```

### Recommendation
To complete the full conversion workflow, you should extract and convert the `networkMultiple` test case instead, which includes:
1. The network infrastructure (from `networkMultipleTemplate`)
2. The actual `azurerm_linux_virtual_machine` resource that needs conversion to AzAPI

## Files Created
- ✅ `azurermacctest/network_multiple_template/main.tf` - Complete runnable Terraform configuration
- ✅ `azurermacctest/network_multiple_template/README.md` - This documentation

## Files NOT Created (and why)
- ❌ `azurerm.tf` - No target resource to extract
- ❌ `azapi.tf.bak` - No target resource to convert
- ❌ `moved.tf.bak` - No resource migration needed
