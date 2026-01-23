variable "location" {
  type        = string
  description = "(Required) The Azure location where the Linux Virtual Machine should exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the Linux Virtual Machine. Changing this forces a new resource to be created."
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.name))
    error_message = "name may only contain alphanumeric characters, dots, dashes and underscores."
  }
  validation {
    condition     = can(regex("^[a-zA-Z0-9]", var.name))
    error_message = "name must begin with an alphanumeric character."
  }
  validation {
    condition     = can(regex("\\w$", var.name))
    error_message = "name must end with an alphanumeric character or underscore."
  }
  validation {
    condition     = !can(regex("^\\d+$", var.name))
    error_message = "name cannot contain only numbers."
  }
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "name must be between 1 and 80 characters in length."
  }
}

variable "network_interface_ids" {
  type        = list(string)
  description = "(Required). A list of Network Interface IDs which should be attached to this Virtual Machine. The first Network Interface ID in this list will be the Primary Network Interface on the Virtual Machine."
  nullable    = false

  validation {
    condition     = length(var.network_interface_ids) >= 1
    error_message = "At least one Network Interface ID must be provided."
  }
  validation {
    condition = alltrue([
      for id in var.network_interface_ids :
      can(regex("^/subscriptions/[a-fA-F0-9-]+/resourceGroups/[^/]+/providers/Microsoft.Network/networkInterfaces/[^/]+$", id))
    ])
    error_message = "Each network_interface_ids element must be a valid Azure Network Interface ID."
  }
}

variable "os_disk" {
  type = object({
    caching                          = string
    disk_encryption_set_id           = optional(string)
    disk_size_gb                     = optional(number)
    name                             = optional(string)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
    storage_account_type             = string
    write_accelerator_enabled        = optional(bool)
    diff_disk_settings = optional(object({
      option    = string
      placement = optional(string)
    }))
  })
  description = <<-EOT
 - `caching` - (Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`.
 - `disk_encryption_set_id` - (Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. Conflicts with `secure_vm_disk_encryption_set_id`.
 - `disk_size_gb` - (Optional) The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
 - `name` - (Optional) The name which should be used for the Internal OS Disk. Changing this forces a new resource to be created.
 - `secure_vm_disk_encryption_set_id` - (Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk when the Virtual Machine is a Confidential VM. Conflicts with `disk_encryption_set_id`. Changing this forces a new resource to be created.
 - `security_encryption_type` - (Optional) Encryption Type when the Virtual Machine is a Confidential VM. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`. Changing this forces a new resource to be created.
 - `storage_account_type` - (Optional) The Type of Storage Account which should back this the Internal OS Disk. Possible values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`, `StandardSSD_ZRS` and `Premium_ZRS`. Changing this forces a new resource to be created.
 - `write_accelerator_enabled` - (Optional) Should Write Accelerator be Enabled for this OS Disk? Defaults to `false`.

 ---
 `diff_disk_settings` block supports the following:
 - `option` - (Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is `Local`. Changing this forces a new resource to be created.
 - `placement` - (Optional) Specifies where to store the Ephemeral Disk. Possible values are `CacheDisk`, `ResourceDisk` and `NvmeDisk`. Defaults to `CacheDisk`. Changing this forces a new resource to be created.
EOT
  nullable    = false

  validation {
    condition = (
      var.os_disk == null ||
      var.os_disk.disk_size_gb == null ||
      (var.os_disk.disk_size_gb >= 0 && var.os_disk.disk_size_gb <= 4095)
    )
    error_message = "disk_size_gb must be between 0 and 4095."
  }
  validation {
    condition = var.os_disk == null || contains([
      "None",
      "ReadOnly",
      "ReadWrite"
    ], var.os_disk.caching)
    error_message = "os_disk.caching must be one of: None, ReadOnly, ReadWrite."
  }
  validation {
    condition     = var.os_disk == null || var.os_disk.diff_disk_settings == null || var.os_disk.caching == "ReadOnly"
    error_message = "`diff_disk_settings` can only be set when `caching` is set to `ReadOnly`."
  }
  validation {
    condition     = var.os_disk == null || var.os_disk.diff_disk_settings == null || var.os_disk.diff_disk_settings.option == "Local"
    error_message = "os_disk.diff_disk_settings.option must be 'Local'."
  }
  validation {
    condition = var.os_disk == null || var.os_disk.diff_disk_settings == null || var.os_disk.diff_disk_settings.placement == null || contains([
      "CacheDisk",
      "ResourceDisk",
      "NvmeDisk"
    ], var.os_disk.diff_disk_settings.placement)
    error_message = "os_disk.diff_disk_settings.placement must be one of: CacheDisk, ResourceDisk, NvmeDisk."
  }
  validation {
    condition = var.os_disk == null || contains([
      "Standard_LRS",
      "StandardSSD_LRS",
      "Premium_LRS",
      "StandardSSD_ZRS",
      "Premium_ZRS"
    ], var.os_disk.storage_account_type)
    error_message = "os_disk.storage_account_type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS."
  }
  validation {
    condition     = var.os_disk == null || !(var.os_disk.disk_encryption_set_id != null && var.os_disk.secure_vm_disk_encryption_set_id != null)
    error_message = "os_disk.disk_encryption_set_id and os_disk.secure_vm_disk_encryption_set_id are mutually exclusive and cannot both be set."
  }
  validation {
    condition     = var.os_disk == null || var.os_disk.secure_vm_disk_encryption_set_id == null || var.os_disk.security_encryption_type == "DiskWithVMGuestState"
    error_message = "`secure_vm_disk_encryption_set_id` can only be specified when `security_encryption_type` is set to `DiskWithVMGuestState`."
  }
  validation {
    condition = var.os_disk == null || var.os_disk.security_encryption_type == null || contains([
      "VMGuestStateOnly",
      "DiskWithVMGuestState"
    ], var.os_disk.security_encryption_type)
    error_message = "os_disk.security_encryption_type must be one of: VMGuestStateOnly, DiskWithVMGuestState."
  }
}

variable "size" {
  type        = string
  description = "(Required) The SKU which should be used for this Virtual Machine, such as `Standard_F2`."
  nullable    = false

  validation {
    condition     = var.size != null && var.size != ""
    error_message = "size must not be empty."
  }
}

variable "additional_capabilities" {
  type = object({
    hibernation_enabled = optional(bool, false)
    ultra_ssd_enabled   = optional(bool, false)
  })
  default     = null
  description = <<-EOT
 - `hibernation_enabled` - (Optional) Whether to enable the hibernation capability or not.
 - `ultra_ssd_enabled` - (Optional) Should the capacity to enable Data Disks of the `UltraSSD_LRS` storage account type be supported on this Virtual Machine? Defaults to `false`.
EOT
}

variable "admin_password" {
  type        = string
  ephemeral   = true
  default     = null
  description = "(Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created."

  validation {
    condition     = var.admin_password == null || (length(var.admin_password) >= 6 && length(var.admin_password) <= 72)
    error_message = "admin_password must be between 6 and 72 characters in length."
  }
  validation {
    condition = var.admin_password == null || !contains([
      "abc@123", "P@$$w0rd", "P@ssw0rd", "P@ssword123", "Pa$$word",
      "pass@word1", "Password!", "Password1", "Password22", "iloveyou!"
    ], var.admin_password)
    error_message = "admin_password specified is not allowed. Cannot use common passwords like 'Password1', 'P@ssw0rd', etc."
  }
  validation {
    condition = var.admin_password == null || length([
      for match in [
        can(regex("[a-z]", var.admin_password)),
        can(regex("[A-Z]", var.admin_password)),
        can(regex("[0-9]", var.admin_password)),
        can(regex("[^\\d\\w]", var.admin_password))
      ] : match if match
    ]) >= 3
    error_message = "admin_password must fulfill at least 3 out of 4 conditions: Has lower characters, Has upper characters, Has a digit, Has a special character."
  }
  validation {
    condition     = var.disable_password_authentication != false || var.admin_password != null
    error_message = "admin_password must be specified when disable_password_authentication is set to false."
  }
}

variable "admin_ssh_key" {
  type = set(object({
    public_key = string
    username   = string
  }))
  default     = null
  description = <<-EOT
 - `public_key` - (Required) The Public Key which should be used for authentication, which needs to be in `ssh-rsa` format with at least 2048-bit or in `ssh-ed25519` format. Changing this forces a new resource to be created.
 - `username` - (Required) The Username for which this Public SSH Key should be configured. Changing this forces a new resource to be created.
EOT
}

variable "admin_username" {
  type        = string
  default     = null
  description = "(Optional) The username of the local administrator used for the Virtual Machine. Changing this forces a new resource to be created."

  validation {
    condition     = var.admin_username == null || (length(trimspace(var.admin_username)) >= 1 && length(var.admin_username) <= 64)
    error_message = "admin_username most be between 1 and 64 characters."
  }
  validation {
    condition = var.admin_username == null || !contains([
      "administrator", "admin", "user", "user1", "test", "user2", "test1", "user3", "admin1", "1", "123", "a",
      "actuser", "adm", "admin2", "aspnet", "backup", "console", "david", "guest", "john", "owner", "root",
      "server", "sql", "support", "support_388945a0", "sys", "test2", "test3", "user4", "user5"
    ], var.admin_username)
    error_message = "admin_username specified is not allowed, cannot match: administrator, admin, user, user1, test, user2, test1, user3, admin1, 1, 123, a, actuser, adm, admin2, aspnet, backup, console, david, guest, john, owner, root, server, sql, support, support_388945a0, sys, test2, test3, user4, user5."
  }
}

variable "allow_extension_operations" {
  type        = bool
  default     = true
  description = "(Optional) Should Extension Operations be allowed on this Virtual Machine? Defaults to `true`."
  nullable    = false

  validation {
    condition     = !var.allow_extension_operations || var.provision_vm_agent != false
    error_message = "allow_extension_operations cannot be set to true when provision_vm_agent is set to false."
  }
}

variable "availability_set_id" {
  type        = string
  default     = null
  description = "(Optional) Specifies the ID of the Availability Set in which the Virtual Machine should exist. Changing this forces a new resource to be created."

  validation {
    condition     = can(regex("^/subscriptions/[a-fA-F0-9-]+/resourceGroups/[^/]+/providers/Microsoft.Compute/availabilitySets/[^/]+$", var.availability_set_id)) || var.availability_set_id == null
    error_message = "availability_set_id must be a valid Azure Availability Set ID in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/availabilitySets/{availabilitySetName}"
  }
}

variable "boot_diagnostics" {
  type = object({
    storage_account_uri = optional(string)
  })
  default     = null
  description = <<-EOT
 - `storage_account_uri` - (Optional) The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor.
EOT
}

variable "bypass_platform_safety_checks_on_user_schedule_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether to skip platform scheduled patching when a user schedule is associated with the VM. Defaults to `false`."
  nullable    = false
}

variable "capacity_reservation_group_id" {
  type        = string
  default     = null
  description = "(Optional) Specifies the ID of the Capacity Reservation Group which the Virtual Machine should be allocated to."

  validation {
    condition     = var.capacity_reservation_group_id == null || can(regex("^/subscriptions/[a-fA-F0-9-]+/resourceGroups/[^/]+/providers/Microsoft\\.Compute/capacityReservationGroups/[^/]+$", var.capacity_reservation_group_id))
    error_message = "capacity_reservation_group_id must be a valid Azure Capacity Reservation Group ID."
  }
}

variable "computer_name" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Hostname which should be used for this Virtual Machine. If unspecified this defaults to the value for the `name` field. If the value of the `name` field is not a valid `computer_name`, then you must specify `computer_name`. Changing this forces a new resource to be created."

  validation {
    condition     = var.computer_name == null || (length(trimspace(var.computer_name)) > 0 && length(var.computer_name) <= 64)
    error_message = "computer_name must not be empty and can be at most 64 characters."
  }
  validation {
    condition     = var.computer_name == null || !startswith(var.computer_name, "_")
    error_message = "computer_name cannot begin with an underscore."
  }
  validation {
    condition     = var.computer_name == null || !endswith(var.computer_name, ".")
    error_message = "computer_name cannot end with a period."
  }
  validation {
    condition     = var.computer_name == null || !endswith(var.computer_name, "-")
    error_message = "computer_name cannot end with a dash."
  }
  validation {
    condition     = var.computer_name == null || !can(regex("[\\\\/\"\\[\\]:|<>+=;,?*@&~!#$%^()_{}']", var.computer_name))
    error_message = "computer_name cannot contain the special characters: `\\\\/\\\"[]:|<>+=;,?*@&~!#$%^()_{}'`"
  }
}

variable "custom_data" {
  type        = string
  ephemeral   = true
  default     = null
  description = "(Optional) The Base64-Encoded Custom Data which should be used for this Virtual Machine. Changing this forces a new resource to be created."

  validation {
    condition     = var.custom_data == null || can(base64decode(var.custom_data))
    error_message = "custom_data must be a valid Base64-encoded string."
  }
}

variable "dedicated_host_group_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of a Dedicated Host Group that this Linux Virtual Machine should be run within. Conflicts with `dedicated_host_id`."

  validation {
    condition     = var.dedicated_host_group_id == null || can(regex("^/subscriptions/[a-fA-F0-9-]+/resourceGroups/[^/]+/providers/Microsoft.Compute/hostGroups/[^/]+$", var.dedicated_host_group_id))
    error_message = "dedicated_host_group_id must be a valid Azure Dedicated Host Group ID in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/hostGroups/{hostGroupName}"
  }
}

variable "dedicated_host_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of a Dedicated Host where this machine should be run on. Conflicts with `dedicated_host_group_id`."

  validation {
    condition     = var.dedicated_host_id == null || can(regex("^/subscriptions/[a-fA-F0-9-]+/resourceGroups/[^/]+/providers/Microsoft.Compute/hostGroups/[^/]+/hosts/[^/]+$", var.dedicated_host_id))
    error_message = "dedicated_host_id must be a valid Azure Dedicated Host ID in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/hostGroups/{hostGroupName}/hosts/{hostName}"
  }
  validation {
    condition     = var.dedicated_host_id == null || try(var.dedicated_host_group_id, null) == null
    error_message = "dedicated_host_id cannot be set when dedicated_host_group_id is specified."
  }
}

variable "disable_password_authentication" {
  type        = bool
  default     = null
  description = "(Optional) Should Password Authentication be disabled on this Virtual Machine? Changing this forces a new resource to be created."
}

variable "disk_controller_type" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Disk Controller Type used for this Virtual Machine. Possible values are `SCSI` and `NVMe`."

  validation {
    condition     = var.disk_controller_type == null || contains(["SCSI", "NVMe"], var.disk_controller_type)
    error_message = "disk_controller_type must be either 'SCSI' or 'NVMe'."
  }
}

variable "edge_zone" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Edge Zone within the Azure Region where this Linux Virtual Machine should exist. Changing this forces a new Linux Virtual Machine to be created."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "encryption_at_host_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"

  validation {
    condition     = var.encryption_at_host_enabled != true || try(var.os_disk.security_encryption_type, null) != "DiskWithVMGuestState"
    error_message = "`encryption_at_host_enabled` cannot be set to `true` when `os_disk.0.security_encryption_type` is set to `DiskWithVMGuestState`."
  }
}

variable "eviction_policy" {
  type        = string
  default     = null
  description = "(Optional) Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. Possible values are `Deallocate` and `Delete`. Changing this forces a new resource to be created."

  validation {
    condition     = var.eviction_policy == null || can(regex("^(Deallocate|Delete)$", var.eviction_policy))
    error_message = "eviction_policy must be either 'Deallocate' or 'Delete'."
  }
}

variable "extensions_time_budget" {
  type        = string
  default     = "PT1H30M"
  description = "(Optional) Specifies the duration allocated for all extensions to start. The time duration should be between 15 minutes and 120 minutes (inclusive) and should be specified in ISO 8601 format. Defaults to `PT1H30M`."
  nullable    = false

  validation {
    condition     = can(regex("^PT([0-9]+H)?([0-9]+M)?([0-9]+S)?$", var.extensions_time_budget))
    error_message = "extensions_time_budget must be a valid ISO 8601 duration (e.g., PT1H30M, PT15M, PT2H)."
  }
  validation {
    condition = (
      can(regex("^PT([0-9]+H)?([0-9]+M)?([0-9]+S)?$", var.extensions_time_budget)) ?
      (
        # Parse hours, minutes, seconds
        (length(regexall("([0-9]+)H", var.extensions_time_budget)) > 0 ? tonumber(regexall("([0-9]+)H", var.extensions_time_budget)[0][0]) : 0) * 3600 +
        (length(regexall("([0-9]+)M", var.extensions_time_budget)) > 0 ? tonumber(regexall("([0-9]+)M", var.extensions_time_budget)[0][0]) : 0) * 60 +
        (length(regexall("([0-9]+)S", var.extensions_time_budget)) > 0 ? tonumber(regexall("([0-9]+)S", var.extensions_time_budget)[0][0]) : 0)
        ) >= 900 && (
        (length(regexall("([0-9]+)H", var.extensions_time_budget)) > 0 ? tonumber(regexall("([0-9]+)H", var.extensions_time_budget)[0][0]) : 0) * 3600 +
        (length(regexall("([0-9]+)M", var.extensions_time_budget)) > 0 ? tonumber(regexall("([0-9]+)M", var.extensions_time_budget)[0][0]) : 0) * 60 +
        (length(regexall("([0-9]+)S", var.extensions_time_budget)) > 0 ? tonumber(regexall("([0-9]+)S", var.extensions_time_budget)[0][0]) : 0)
      ) <= 7200 : true
    )
    error_message = "extensions_time_budget must be between PT15M (15 minutes = 900 seconds) and PT2H (2 hours = 7200 seconds)."
  }
}

variable "gallery_application" {
  type = list(object({
    automatic_upgrade_enabled                   = optional(bool, false)
    configuration_blob_uri                      = optional(string)
    order                                       = optional(number)
    tag                                         = optional(string)
    treat_failure_as_deployment_failure_enabled = optional(bool, false)
    version_id                                  = string
  }))
  default     = null
  description = <<-EOT
 - `automatic_upgrade_enabled` - (Optional) Specifies whether the version will be automatically updated for the VM when a new Gallery Application version is available in PIR/SIG. Defaults to `false`.
 - `configuration_blob_uri` - (Optional) Specifies the URI to an Azure Blob that will replace the default configuration for the package if provided.
 - `order` - (Optional) Specifies the order in which the packages have to be installed. Possible values are between `0` and `2147483647`. Defaults to `0`.
 - `tag` - (Optional) Specifies a passthrough value for more generic context. This field can be any valid `string` value.
 - `treat_failure_as_deployment_failure_enabled` - (Optional) Specifies whether any failure for any operation in the VmApplication will fail the deployment of the VM. Defaults to `false`.
 - `version_id` - (Required) Specifies the Gallery Application Version resource ID.
EOT

  validation {
    condition = var.gallery_application == null || alltrue([
      for app in var.gallery_application :
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Compute/galleries/[^/]+/applications/[^/]+/versions/[^/]+$", app.version_id))
    ])
    error_message = "Each version_id must be a valid Gallery Application Version resource ID in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/galleries/{galleryName}/applications/{applicationName}/versions/{versionName}"
  }
  validation {
    condition = var.gallery_application == null || alltrue([
      for app in var.gallery_application :
      app.configuration_blob_uri == null || can(regex("^https?://", app.configuration_blob_uri))
    ])
    error_message = "Each configuration_blob_uri must be a valid HTTP or HTTPS URL."
  }
  validation {
    condition = var.gallery_application == null || alltrue([
      for app in var.gallery_application :
      app.order == null || (app.order >= 0 && app.order <= 2147483647)
    ])
    error_message = "Each order must be between 0 and 2147483647."
  }
  validation {
    condition = var.gallery_application == null || alltrue([
      for app in var.gallery_application :
      app.tag == null || length(trimspace(app.tag)) > 0
    ])
    error_message = "Each tag must not be empty if specified."
  }
}

variable "identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default     = null
  description = <<-EOT
 - `identity_ids` - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Linux Virtual Machine.
 - `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both).
EOT

  validation {
    condition = var.identity == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity.type)
    error_message = "identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
  validation {
    condition = (
      var.identity == null ||
      var.identity.identity_ids == null ||
      length(var.identity.identity_ids) == 0 ||
      var.identity.type == "UserAssigned" ||
      var.identity.type == "SystemAssigned, UserAssigned"
    )
    error_message = "identity_ids can only be specified when type is set to \"UserAssigned\" or \"SystemAssigned, UserAssigned\"."
  }
}

variable "license_type" {
  type        = string
  default     = null
  description = "(Optional) Specifies the License Type for this Virtual Machine. Possible values are `RHEL_BYOS`, `RHEL_BASE`, `RHEL_EUS`, `RHEL_SAPAPPS`, `RHEL_SAPHA`, `RHEL_BASESAPAPPS`, `RHEL_BASESAPHA`, `SLES_BYOS`, `SLES_SAP`, `SLES_HPC`, `UBUNTU_PRO`."

  validation {
    condition = var.license_type == null || contains([
      "RHEL_BYOS",
      "RHEL_BASE",
      "RHEL_EUS",
      "RHEL_SAPAPPS",
      "RHEL_SAPHA",
      "RHEL_BASESAPAPPS",
      "RHEL_BASESAPHA",
      "SLES_BYOS",
      "SLES_SAP",
      "SLES_HPC",
      "UBUNTU_PRO"
    ], var.license_type)
    error_message = "license_type must be one of: RHEL_BYOS, RHEL_BASE, RHEL_EUS, RHEL_SAPAPPS, RHEL_SAPHA, RHEL_BASESAPAPPS, RHEL_BASESAPHA, SLES_BYOS, SLES_SAP, SLES_HPC, UBUNTU_PRO."
  }
}

variable "max_bid_price" {
  type        = number
  default     = -1
  description = "(Optional) The maximum price you're willing to pay for this Virtual Machine, in US Dollars; which must be greater than the current spot price. If this bid price falls below the current spot price the Virtual Machine will be evicted using the `eviction_policy`. Defaults to `-1`, which means that the Virtual Machine should not be evicted for price reasons."
  nullable    = false

  validation {
    condition     = var.max_bid_price >= -1
    error_message = "max_bid_price must be greater than or equal to -1."
  }
  validation {
    condition     = var.max_bid_price <= 0 || var.priority == "Spot"
    error_message = "max_bid_price can only be configured when priority is set to Spot."
  }
}

variable "os_image_notification" {
  type = object({
    timeout = optional(string, "PT15M")
  })
  default     = null
  description = <<-EOT
 - `timeout` - (Optional) Length of time a notification to be sent to the VM on the instance metadata server till the VM gets OS upgraded. The only possible value is `PT15M`. Defaults to `PT15M`.
EOT

  validation {
    condition = (
      var.os_image_notification == null ||
      var.os_image_notification.timeout == null ||
      var.os_image_notification.timeout == "PT15M"
    )
    error_message = "timeout must be PT15M."
  }
}

variable "os_managed_disk_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of an existing OS Managed Disk which should be attached to this Virtual Machine. When using this field you must also specify `os_disk.caching`. Conflicts with `source_image_id` and `source_image_reference`."

  validation {
    condition = (
      (var.source_image_id != null ? 1 : 0) +
      (var.source_image_reference != null ? 1 : 0) +
      (var.os_managed_disk_id != null ? 1 : 0)
    ) <= 1
    error_message = "Only one of source_image_id, source_image_reference, or os_managed_disk_id can be specified."
  }
  validation {
    condition     = var.os_managed_disk_id == null || var.custom_data == null
    error_message = "custom_data cannot be set when os_managed_disk_id is specified."
  }
  validation {
    condition     = var.os_managed_disk_id == null || var.patch_assessment_mode == null
    error_message = "patch_assessment_mode cannot be specified when os_managed_disk_id is set."
  }
  validation {
    condition     = var.os_managed_disk_id == null || var.patch_mode == "ImageDefault"
    error_message = "patch_mode conflicts with os_managed_disk_id. When os_managed_disk_id is specified, patch_mode must be set to its default value 'ImageDefault'."
  }
  validation {
    condition     = var.os_managed_disk_id == null || !var.bypass_platform_safety_checks_on_user_schedule_enabled
    error_message = "bypass_platform_safety_checks_on_user_schedule_enabled cannot be set to true when os_managed_disk_id is specified."
  }
  validation {
    condition     = var.os_managed_disk_id == null || var.computer_name == null
    error_message = "computer_name cannot be set when os_managed_disk_id is specified."
  }
  validation {
    condition     = var.os_managed_disk_id == null || var.admin_password == null
    error_message = "admin_password cannot be set when os_managed_disk_id is specified."
  }
}

variable "patch_assessment_mode" {
  type        = string
  default     = null
  description = "(Optional) Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are `AutomaticByPlatform` or `ImageDefault`. Defaults to `ImageDefault`."

  validation {
    condition = var.patch_assessment_mode == null || contains([
      "AutomaticByPlatform",
      "ImageDefault"
    ], var.patch_assessment_mode)
    error_message = "patch_assessment_mode must be either 'AutomaticByPlatform' or 'ImageDefault'."
  }
  validation {
    condition = (
      var.patch_assessment_mode != "AutomaticByPlatform" ||
      var.provision_vm_agent == true
    )
    error_message = "`provision_vm_agent` must be set to `true` when `patch_assessment_mode` is set to `AutomaticByPlatform`."
  }
}

variable "patch_mode" {
  type        = string
  default     = "ImageDefault"
  description = "(Optional) Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are `AutomaticByPlatform` and `ImageDefault`. Defaults to `ImageDefault`. For more information on patch modes please see the [product documentation](https://docs.microsoft.com/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes)."
  nullable    = false

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patch_mode)
    error_message = "patch_mode must be one of: AutomaticByPlatform, ImageDefault."
  }
  validation {
    condition     = var.patch_mode != "AutomaticByPlatform" || var.provision_vm_agent
    error_message = "`patch_mode` cannot be set to `AutomaticByPlatform` when `provision_vm_agent` is set to `false`."
  }
  validation {
    condition     = !var.bypass_platform_safety_checks_on_user_schedule_enabled || var.patch_mode == "AutomaticByPlatform"
    error_message = "`patch_mode` must be set to `AutomaticByPlatform` when `bypass_platform_safety_checks_on_user_schedule_enabled` is set to `true`."
  }
  validation {
    condition     = var.reboot_setting == null || var.patch_mode == "AutomaticByPlatform"
    error_message = "`patch_mode` must be set to `AutomaticByPlatform` when `reboot_setting` is specified."
  }
}

variable "plan" {
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default     = null
  description = <<-EOT
 - `name` - (Required) Specifies the Name of the Marketplace Image this Virtual Machine should be created from. Changing this forces a new resource to be created.
 - `product` - (Required) Specifies the Product of the Marketplace Image this Virtual Machine should be created from. Changing this forces a new resource to be created.
 - `publisher` - (Required) Specifies the Publisher of the Marketplace Image this Virtual Machine should be created from. Changing this forces a new resource to be created.
EOT
}

variable "platform_fault_domain" {
  type        = number
  default     = -1
  description = "(Optional) Specifies the Platform Fault Domain in which this Linux Virtual Machine should be created. Defaults to `-1`, which means this will be automatically assigned to a fault domain that best maintains balance across the available fault domains. Changing this forces a new Linux Virtual Machine to be created."
  nullable    = false

  validation {
    condition     = var.platform_fault_domain >= -1
    error_message = "platform_fault_domain must be at least -1."
  }
  validation {
    condition     = var.platform_fault_domain == -1 || var.virtual_machine_scale_set_id != null
    error_message = "virtual_machine_scale_set_id must be set when platform_fault_domain is not -1."
  }
}

variable "priority" {
  type        = string
  default     = "Regular"
  description = "(Optional) Specifies the priority of this Virtual Machine. Possible values are `Regular` and `Spot`. Defaults to `Regular`. Changing this forces a new resource to be created."
  nullable    = false

  validation {
    condition     = can(regex("^(Regular|Spot)$", var.priority))
    error_message = "priority must be either 'Regular' or 'Spot'."
  }
  validation {
    condition     = var.priority != "Spot" || var.eviction_policy != null
    error_message = "eviction_policy must be specified when priority is set to 'Spot'."
  }
}

variable "provision_vm_agent" {
  type        = bool
  default     = true
  description = "(Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to `true`. Changing this forces a new resource to be created."
  nullable    = false
}

variable "proximity_placement_group_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Proximity Placement Group which the Virtual Machine should be assigned to."

  validation {
    condition     = var.proximity_placement_group_id == null || try(var.capacity_reservation_group_id, null) == null
    error_message = "proximity_placement_group_id cannot be set when capacity_reservation_group_id is specified."
  }
}

variable "reboot_setting" {
  type        = string
  default     = null
  description = "(Optional) Specifies the reboot setting for platform scheduled patching. Possible values are `Always`, `IfRequired` and `Never`."

  validation {
    condition = var.reboot_setting == null || contains([
      "Always",
      "IfRequired",
      "Never"
    ], var.reboot_setting)
    error_message = "reboot_setting must be one of: Always, IfRequired, Never."
  }
}

variable "secret" {
  type = list(object({
    key_vault_id = string
    certificate = set(object({
      url = string
    }))
  }))
  default     = null
  description = <<-EOT
 - `key_vault_id` - (Required) The ID of the Key Vault from which all Secrets should be sourced.

 ---
 `certificate` block supports the following:
 - `url` - (Required) The Secret URL of a Key Vault Certificate.
EOT
}

variable "secure_boot_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Specifies whether secure boot should be enabled on the virtual machine. Changing this forces a new resource to be created."

  validation {
    condition     = try(var.os_disk.security_encryption_type != "DiskWithVMGuestState", true) || var.secure_boot_enabled == true
    error_message = "`secure_boot_enabled` must be set to `true` when `os_disk.0.security_encryption_type` is set to `DiskWithVMGuestState`."
  }
}

variable "source_image_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created. Possible Image ID types include `Image ID`s, `Shared Image ID`s, `Shared Image Version ID`s, `Community Gallery Image ID`s, `Community Gallery Image Version ID`s, `Shared Gallery Image ID`s and `Shared Gallery Image Version ID`s."
}

variable "source_image_reference" {
  type = object({
    offer     = string
    publisher = string
    sku       = string
    version   = string
  })
  default     = null
  description = <<-EOT
 - `offer` - (Required) Specifies the offer of the image used to create the virtual machines. Changing this forces a new resource to be created.
 - `publisher` - (Required) Specifies the publisher of the image used to create the virtual machines. Changing this forces a new resource to be created.
 - `sku` - (Required) Specifies the SKU of the image used to create the virtual machines. Changing this forces a new resource to be created.
 - `version` - (Required) Specifies the version of the image used to create the virtual machines. Changing this forces a new resource to be created.
EOT

  validation {
    condition     = var.source_image_reference == null || length(trimspace(var.source_image_reference.offer)) > 0
    error_message = "offer must not be empty when source_image_reference is specified."
  }
  validation {
    condition     = var.source_image_reference == null || length(trimspace(var.source_image_reference.publisher)) > 0
    error_message = "publisher must not be empty when source_image_reference is specified."
  }
  validation {
    condition     = var.source_image_reference == null || length(trimspace(var.source_image_reference.sku)) > 0
    error_message = "sku must not be empty when source_image_reference is specified."
  }
  validation {
    condition     = var.source_image_reference == null || length(trimspace(var.source_image_reference.version)) > 0
    error_message = "version must not be empty when source_image_reference is specified."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags which should be assigned to this Virtual Machine."
}

variable "termination_notification" {
  type = object({
    enabled = bool
    timeout = optional(string, "PT5M")
  })
  default     = null
  description = <<-EOT
 - `enabled` - (Required) Should the termination notification be enabled on this Virtual Machine?
 - `timeout` - (Optional) Length of time (in minutes, between `5` and `15`) a notification to be sent to the VM on the instance metadata server till the VM gets deleted. The time duration should be specified in ISO 8601 format. Defaults to `PT5M`.
EOT

  validation {
    condition = (
      var.termination_notification == null ||
      can(regex("^PT([5-9]|1[0-5])M$", var.termination_notification.timeout))
    )
    error_message = "timeout must be an ISO 8601 duration between PT5M and PT15M (5 to 15 minutes)."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string, "45m")
    delete = optional(string, "45m")
    read   = optional(string, "5m")
    update = optional(string, "45m")
  })
  default = {
    create = "45m"
    delete = "45m"
    read   = "5m"
    update = "45m"
  }
  description = <<-EOT
 - `create` - (Optional) Specifies the timeout for create operations. Defaults to 45 minutes.
 - `delete` - (Optional) Specifies the timeout for delete operations. Defaults to 45 minutes.
 - `read` - (Optional) Specifies the timeout for read operations. Defaults to 5 minutes.
 - `update` - (Optional) Specifies the timeout for update operations. Defaults to 45 minutes.
EOT
  nullable    = false
}

variable "user_data" {
  type        = string
  default     = null
  description = "(Optional) The Base64-Encoded User Data which should be used for this Virtual Machine."

  validation {
    condition     = var.user_data == null || can(base64decode(var.user_data))
    error_message = "user_data must be Base64 encoded."
  }
}

variable "virtual_machine_scale_set_id" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Orchestrated Virtual Machine Scale Set that this Virtual Machine should be created within."

  validation {
    condition     = var.virtual_machine_scale_set_id == null || try(var.availability_set_id, null) == null
    error_message = "virtual_machine_scale_set_id cannot be set when availability_set_id is specified."
  }
}

variable "vtpm_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Specifies whether vTPM should be enabled on the virtual machine. Changing this forces a new resource to be created."
}

variable "zone" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Availability Zones in which this Linux Virtual Machine should be located. Changing this forces a new Linux Virtual Machine to be created."

  validation {
    condition     = var.zone == null || try(var.availability_set_id, null) == null
    error_message = "zone cannot be set when availability_set_id is specified."
  }
}
