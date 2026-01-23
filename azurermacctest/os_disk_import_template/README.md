# Test Case: osDiskImportTemplate

## Description
This is a helper/template test case method that provides base infrastructure (resource group, virtual network, subnet, and network interface) for other test cases. It does not contain an `azurerm_linux_virtual_machine` resource itself.

## Status
- **Part 1 (Extraction)**: ✅ Complete
- **Part 2 (AzAPI Conversion)**: N/A - No VM resource to convert

## Usage
This template is used by other test cases such as:
- `diskOSImportManagedDisk`
- `diskOSImportManagedDiskWithSize`
- `diskOSImportManagedDiskCleanup`

## Files
- `main.tf` - Contains providers, random resources, and supporting infrastructure only
