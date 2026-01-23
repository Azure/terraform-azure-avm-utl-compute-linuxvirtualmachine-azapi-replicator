# Acceptance Tests for azurerm_linux_virtual_machine

This directory contains acceptance tests extracted from the Terraform AzureRM provider test suite.

## Test Organization

Tests are organized by category matching the structure in `test_cases.md`:

### Directory Structure

```
acceptance/
├── basic/                    # Basic/Foundation Cases (11 tests)
├── image/                    # Image Configuration Cases (6 tests)
├── disk_os/                  # OS Disk Configuration Cases (23 tests)
├── scaling/                  # Scaling and Capacity Cases (28 tests)
├── network/                  # Network Configuration Cases (22 tests)
├── identity/                 # Identity Configuration Cases (8 tests)
├── orchestrated/             # Orchestrated VMSS Cases (10 tests)
└── advanced/                 # Advanced Configuration Cases (48 tests)
```

## Total Test Cases

**169 valid acceptance test cases** extracted from the following source files:

- linux_virtual_machine_resource_test.go
- linux_virtual_machine_resource_auth_test.go
- linux_virtual_machine_resource_other_test.go
- linux_virtual_machine_resource_images_test.go
- linux_virtual_machine_resource_disk_os_test.go
- linux_virtual_machine_resource_scaling_test.go
- linux_virtual_machine_resource_network_test.go
- linux_virtual_machine_resource_identity_test.go
- linux_virtual_machine_resource_orchestrated_test.go

## Test Case Structure

Each test case directory contains:
- `main.tf` - Complete Terraform configuration for the test
- `README.md` - Description and source information

## Running Tests

Individual tests can be run using standard Terraform commands:

```bash
cd tests/acceptance/<category>/<test_name>
terraform init
terraform plan
terraform apply
terraform destroy
```

## Source

Test cases are extracted from:
- **Repository**: hashicorp/terraform-provider-azurerm
- **Branch**: main
- **Base Path**: internal/services/compute/

## Notes

- All test cases use `eastus` as the default location
- Placeholders have been replaced with Terraform random resources
- Each test is a complete, runnable configuration
