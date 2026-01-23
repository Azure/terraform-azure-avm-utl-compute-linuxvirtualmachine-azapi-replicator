# terraform-azure-avm-utl-compute-linuxvirtualmachine-azapi-replicator

This Azure Verified Module (AVM) utility module provides a migration path from `azurerm_linux_virtual_machine` resource to the generic `azapi_resource` provider. It acts as a replicator that accepts the same input variables as the AzureRM provider and outputs the necessary configurations for AzAPI resource deployment.

## Purpose

This module is designed to:
- **Facilitate migration** from AzureRM provider to AzAPI provider for subnet resources
- **Maintain compatibility** with existing `azurerm_linux_virtual_machine` configurations
- **Generate AzAPI outputs** including resource headers, body, locks, and sensitive data

## Key Features

- ✅ **Full feature parity** with `azurerm_linux_virtual_machine` resource
- ✅ **Schema validation disabled** to support all Azure API fields including read-only properties
- ✅ **Automatic state migration** support via output configurations
- ✅ **Comprehensive validation** for input parameters
- ✅ **Telemetry support** (opt-in/opt-out)
- ✅ **Lock management** for safe concurrent operations