# Azure Resource Migration Plan: azurerm_linux_virtual_machine to azapi_resource

## Resource Identification

**Source Resource Type:** `azurerm_linux_virtual_machine`

**Target AzAPI Resource Type:** `Microsoft.Compute/virtualMachines`

**API Version:** `2024-03-01`

## Evidence and Proof

The resource type and API version were identified from the AzureRM provider source code:

1. **Import Path Evidence:** The create function imports `"github.com/hashicorp/go-azure-sdk/resource-manager/compute/2024-03-01/virtualmachines"`, which indicates the API version is `2024-03-01`.

2. **Resource Type Construction:** In the create function, the resource ID is constructed using:
   ```go
   id := virtualmachines.NewVirtualMachineID(subscriptionId, d.Get("resource_group_name").(string), d.Get("name").(string))
   ```
   This follows Azure's standard resource ID format for `Microsoft.Compute/virtualMachines`.

3. **API Client Usage:** The create function uses:
   ```go
   client := meta.(*clients.Client).Compute.VirtualMachinesClient
   ```
   which operates on the Virtual Machines resource type.

4. **VirtualMachine Type Definition:** The Go SDK type `VirtualMachine` in package `github.com/hashicorp/go-azure-sdk/resource-manager/compute/2024-03-01/virtualmachines` represents the Azure resource `Microsoft.Compute/virtualMachines`.

5. **Available API Versions:** The Azure API supports multiple versions including: 2024-11-01, 2024-07-01, **2024-03-01** (used by provider), 2023-09-01, and earlier versions.

## Planning Task List

| No. | Path | Type | Required | Status | Proof Doc Markdown Link |
|-----|------|------|----------|--------|-------------------------|
| 1 | name | Argument | Yes | ✅ Completed | [1.name.md](1.name.md) |
| 2 | resource_group_name | Argument | Yes | ✅ Completed | [2.resource_group_name.md](2.resource_group_name.md) |
| 3 | location | Argument | Yes | ✅ Completed | [3.location.md](3.location.md) |
| 4 | network_interface_ids | Argument | Yes | ✅ Completed | [4.network_interface_ids.md](4.network_interface_ids.md) |
| 5 | size | Argument | Yes | ✅ Completed | [5.size.md](5.size.md) |
| 6 | admin_password | Argument | No | ✅ Completed | [6.admin_password.md](6.admin_password.md) |
| 7 | admin_username | Argument | No | ✅ Completed | [7.admin_username.md](7.admin_username.md) |
| 8 | allow_extension_operations | Argument | No | ✅ Completed | [8.allow_extension_operations.md](8.allow_extension_operations.md) |
| 9 | availability_set_id | Argument | No | ✅ Completed | [9.availability_set_id.md](9.availability_set_id.md) |
| 10 | bypass_platform_safety_checks_on_user_schedule_enabled | Argument | No | ✅ Completed | [10.bypass_platform_safety_checks_on_user_schedule_enabled.md](10.bypass_platform_safety_checks_on_user_schedule_enabled.md) |
| 11 | capacity_reservation_group_id | Argument | No | ✅ Completed | [11.capacity_reservation_group_id.md](11.capacity_reservation_group_id.md) |
| 12 | computer_name | Argument | No | ✅ Completed | [12.computer_name.md](12.computer_name.md) |
| 13 | custom_data | Argument | No | ✅ Completed | [13.custom_data.md](13.custom_data.md) |
| 14 | dedicated_host_group_id | Argument | No | ✅ Completed | [14.dedicated_host_group_id.md](14.dedicated_host_group_id.md) |
| 15 | dedicated_host_id | Argument | No | ✅ Completed | [15.dedicated_host_id.md](15.dedicated_host_id.md) |
| 16 | disable_password_authentication | Argument | No | ✅ Completed | [16.disable_password_authentication.md](16.disable_password_authentication.md) |
| 17 | disk_controller_type | Argument | No | ✅ Completed | [17.disk_controller_type.md](17.disk_controller_type.md) |
| 18 | edge_zone | Argument | No | ✅ Completed | [18.edge_zone.md](18.edge_zone.md) |
| 19 | encryption_at_host_enabled | Argument | No | ✅ Completed | [19.encryption_at_host_enabled.md](19.encryption_at_host_enabled.md) |
| 20 | eviction_policy | Argument | No | ✅ Completed | [20.eviction_policy.md](20.eviction_policy.md) |
| 21 | extensions_time_budget | Argument | No | ✅ Completed | [21.extensions_time_budget.md](21.extensions_time_budget.md) |
| 22 | license_type | Argument | No | ✅ Completed | [22.license_type.md](22.license_type.md) |
| 23 | max_bid_price | Argument | No | ✅ Completed | [23.max_bid_price.md](23.max_bid_price.md) |
| 24 | os_managed_disk_id | Argument | No | Pending for check | [24.os_managed_disk_id.md](24.os_managed_disk_id.md) |
| 25 | patch_assessment_mode | Argument | No | ✅ Completed | [25.patch_assessment_mode.md](25.patch_assessment_mode.md) |
| 26 | patch_mode | Argument | No | ✅ Completed | [26.patch_mode.md](26.patch_mode.md) |
| 27 | platform_fault_domain | Argument | No | ✅ Completed | [27.platform_fault_domain.md](27.platform_fault_domain.md) |
| 28 | priority | Argument | No | ✅ Completed | [28.priority.md](28.priority.md) |
| 29 | provision_vm_agent | Argument | No | ✅ Completed | [29.provision_vm_agent.md](29.provision_vm_agent.md) |
| 30 | proximity_placement_group_id | Argument | No | ✅ Completed | [30.proximity_placement_group_id.md](30.proximity_placement_group_id.md) |
| 31 | reboot_setting | Argument | No | ✅ Completed | [31.reboot_setting.md](31.reboot_setting.md) |
| 32 | secure_boot_enabled | Argument | No | ✅ Completed | [32.secure_boot_enabled.md](32.secure_boot_enabled.md) |
| 33 | source_image_id | Argument | No | ✅ Completed | [33.source_image_id.md](33.source_image_id.md) |
| 34 | tags | Argument | No | ✅ Completed | [34.tags.md](34.tags.md) |
| 35 | user_data | Argument | No | ✅ Completed | [35.user_data.md](35.user_data.md) |
| 36 | virtual_machine_scale_set_id | Argument | No | ✅ Completed | [36.virtual_machine_scale_set_id.md](36.virtual_machine_scale_set_id.md) |
| 37 | vm_agent_platform_updates_enabled | Argument | No | ✅ Completed | [37.vm_agent_platform_updates_enabled.md](37.vm_agent_platform_updates_enabled.md) |
| 38 | vtpm_enabled | Argument | No | ✅ Completed | [38.vtpm_enabled.md](38.vtpm_enabled.md) |
| 39 | zone | Argument | No | ✅ Completed | [39.zone.md](39.zone.md) |
| 40 | __check_root_hidden_fields__ | HiddenFieldsCheck | Yes | ✅ Completed | [40.__check_root_hidden_fields__.md](40.__check_root_hidden_fields__.md) |
| 41 | os_disk | Block | Yes | ✅ Completed | [41.os_disk.md](41.os_disk.md) |
| 42 | os_disk.caching | Argument | Yes | ✅ Completed | [42.os_disk.caching.md](42.os_disk.caching.md) |
| 43 | os_disk.storage_account_type | Argument | No | ✅ Completed | [43.os_disk.storage_account_type.md](43.os_disk.storage_account_type.md) |
| 44 | os_disk.disk_encryption_set_id | Argument | No | ✅ Completed | [44.os_disk.disk_encryption_set_id.md](44.os_disk.disk_encryption_set_id.md) |
| 45 | os_disk.disk_size_gb | Argument | No | ✅ Completed | [45.os_disk.disk_size_gb.md](45.os_disk.disk_size_gb.md) |
| 46 | os_disk.name | Argument | No | ✅ Completed | [46.os_disk.name.md](46.os_disk.name.md) |
| 47 | os_disk.secure_vm_disk_encryption_set_id | Argument | No | ✅ Completed | [47.os_disk.secure_vm_disk_encryption_set_id.md](47.os_disk.secure_vm_disk_encryption_set_id.md) |
| 48 | os_disk.security_encryption_type | Argument | No | ✅ Completed | [48.os_disk.security_encryption_type.md](48.os_disk.security_encryption_type.md) |
| 49 | os_disk.write_accelerator_enabled | Argument | No | ✅ Completed | [49.os_disk.write_accelerator_enabled.md](49.os_disk.write_accelerator_enabled.md) |
| 50 | os_disk.diff_disk_settings | Block | No | ✅ Completed | [50.os_disk.diff_disk_settings.md](50.os_disk.diff_disk_settings.md) |
| 51 | os_disk.diff_disk_settings.option | Argument | Yes | ✅ Completed | [51.os_disk.diff_disk_settings.option.md](51.os_disk.diff_disk_settings.option.md) |
| 52 | os_disk.diff_disk_settings.placement | Argument | No | ✅ Completed | [52.os_disk.diff_disk_settings.placement.md](52.os_disk.diff_disk_settings.placement.md) |
| 53 | additional_capabilities | Block | No | ✅ Completed | [53.additional_capabilities.md](53.additional_capabilities.md) |
| 54 | additional_capabilities.hibernation_enabled | Argument | No | ✅ Completed | [54.additional_capabilities.hibernation_enabled.md](54.additional_capabilities.hibernation_enabled.md) |
| 55 | additional_capabilities.ultra_ssd_enabled | Argument | No | ✅ Completed | [55.additional_capabilities.ultra_ssd_enabled.md](55.additional_capabilities.ultra_ssd_enabled.md) |
| 56 | admin_ssh_key | Block | No | ✅ Completed | [56.admin_ssh_key.md](56.admin_ssh_key.md) |
| 57 | admin_ssh_key.public_key | Argument | Yes | ✅ Completed | [57.admin_ssh_key.public_key.md](57.admin_ssh_key.public_key.md) |
| 58 | admin_ssh_key.username | Argument | Yes | ✅ Completed | [58.admin_ssh_key.username.md](58.admin_ssh_key.username.md) |
| 59 | boot_diagnostics | Block | No | ✅ Completed | [59.boot_diagnostics.md](59.boot_diagnostics.md) |
| 60 | boot_diagnostics.storage_account_uri | Argument | No | ✅ Completed | [60.boot_diagnostics.storage_account_uri.md](60.boot_diagnostics.storage_account_uri.md) |
| 61 | gallery_application | Block | No | ✅ Completed | [61.gallery_application.md](61.gallery_application.md) |
| 62 | gallery_application.version_id | Argument | Yes | ✅ Completed | [62.gallery_application.version_id.md](62.gallery_application.version_id.md) |
| 63 | gallery_application.automatic_upgrade_enabled | Argument | No | ✅ Completed | [63.gallery_application.automatic_upgrade_enabled.md](63.gallery_application.automatic_upgrade_enabled.md) |
| 64 | gallery_application.configuration_blob_uri | Argument | No | ✅ Completed | [64.gallery_application.configuration_blob_uri.md](64.gallery_application.configuration_blob_uri.md) |
| 65 | gallery_application.order | Argument | No | ✅ Completed | [65.gallery_application.order.md](65.gallery_application.order.md) |
| 66 | gallery_application.tag | Argument | No | ✅ Completed | [66.gallery_application.tag.md](66.gallery_application.tag.md) |
| 67 | gallery_application.treat_failure_as_deployment_failure_enabled | Argument | No | ✅ Completed | [67.gallery_application.treat_failure_as_deployment_failure_enabled.md](67.gallery_application.treat_failure_as_deployment_failure_enabled.md) |
| 68 | identity | Block | No | ✅ Completed | [68.identity.md](68.identity.md) |
| 69 | identity.type | Argument | Yes | ✅ Completed | [69.identity.type.md](69.identity.type.md) |
| 70 | identity.identity_ids | Argument | No | ✅ Completed | [70.identity.identity_ids.md](70.identity.identity_ids.md) |
| 71 | os_image_notification | Block | No | ✅ Completed | [71.os_image_notification.md](71.os_image_notification.md) |
| 72 | os_image_notification.timeout | Argument | No | ✅ Completed | [72.os_image_notification.timeout.md](72.os_image_notification.timeout.md) |
| 73 | plan | Block | No | ✅ Completed | [73.plan.md](73.plan.md) |
| 74 | plan.name | Argument | Yes | ✅ Completed | [74.plan.name.md](74.plan.name.md) |
| 75 | plan.product | Argument | Yes | ✅ Completed | [75.plan.product.md](75.plan.product.md) |
| 76 | plan.publisher | Argument | Yes | ✅ Completed | [76.plan.publisher.md](76.plan.publisher.md) |
| 77 | secret | Block | No | ✅ Completed | [77.secret.md](77.secret.md) |
| 78 | secret.key_vault_id | Argument | Yes | ✅ Completed | [77.secret.md](77.secret.md) |
| 79 | secret.certificate | Block | Yes | ✅ Completed | [77.secret.md](77.secret.md) |
| 80 | secret.certificate.url | Argument | Yes | ✅ Completed | [77.secret.md](77.secret.md) |
| 81 | source_image_reference | Block | No | ✅ Completed | [81.source_image_reference.md](81.source_image_reference.md) |
| 82 | source_image_reference.offer | Argument | Yes | ✅ Completed | [82.source_image_reference.offer.md](82.source_image_reference.offer.md) |
| 83 | source_image_reference.publisher | Argument | Yes | ✅ Completed | [83.source_image_reference.publisher.md](83.source_image_reference.publisher.md) |
| 84 | source_image_reference.sku | Argument | Yes | ✅ Completed | [84.source_image_reference.sku.md](84.source_image_reference.sku.md) |
| 85 | source_image_reference.version | Argument | Yes | ✅ Completed | [85.source_image_reference.version.md](85.source_image_reference.version.md) |
| 86 | termination_notification | Block | No | ✅ Completed | [86.termination_notification.md](86.termination_notification.md) |
| 87 | termination_notification.enabled | Argument | Yes | ✅ Completed | [87.termination_notification.enabled.md](87.termination_notification.enabled.md) |
| 88 | termination_notification.timeout | Argument | No | ✅ Completed | [88.termination_notification.timeout.md](88.termination_notification.timeout.md) |
| 89 | timeouts | Block | No | ✅ Completed | [89.timeouts.md](89.timeouts.md) |
| 90 | timeouts.create | Argument | No | ✅ Completed | [90.timeouts.create.md](90.timeouts.create.md) |
| 91 | timeouts.delete | Argument | No | ✅ Completed | [91.timeouts.delete.md](91.timeouts.delete.md) |
| 92 | timeouts.read | Argument | No | ✅ Completed | [92.timeouts.read.md](92.timeouts.read.md) |
| 93 | timeouts.update | Argument | No | ✅ Completed | [93.timeouts.update.md](93.timeouts.update.md) |

## Notes

1. **Timeouts Block:** The resource supports timeouts configuration via `pluginsdk.ResourceTimeout` with the following default values:
   - Create: 45 minutes
   - Read: 5 minutes
   - Update: 45 minutes
   - Delete: 45 minutes

2. **Computed Fields:** The following fields are computed-only and should not be included in the azapi_resource body:
   - `private_ip_address`
   - `private_ip_addresses`
   - `public_ip_address`
   - `public_ip_addresses`
   - `virtual_machine_id`
   - `os_disk.id`

3. **Conditional Logic:** Several fields have complex conditional requirements:
   - `admin_username` is in an ExactlyOneOf relationship with `os_managed_disk_id`
   - `source_image_id` and `source_image_reference` are mutually exclusive with `os_managed_disk_id`
   - `patch_mode` set to `AutomaticByPlatform` requires `provision_vm_agent` to be `true`
   - `eviction_policy` can only be set when `priority` is `Spot`

4. **Multi-Item Blocks:** The following blocks can appear multiple times:
   - `admin_ssh_key` (TypeSet)
   - `gallery_application` (up to 100 items)
   - `secret` (TypeList)

5. **API Version Selection:** Using API version `2024-03-01` as it's the version actively used by the AzureRM provider. Later versions (2024-07-01, 2024-11-01) are also available if needed.
