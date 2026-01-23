locals {
  resource_group_id = var.resource_group_id
}

locals {
  admin_password_should_suppress = (
    local.existing_admin_password == "ignored-as-imported" ||
    local.desired_admin_password == "ignored-as-imported"
  )
  azapi_header = {
    type                 = "Microsoft.Compute/virtualMachines@2024-03-01"
    name                 = var.name
    location             = var.location
    parent_id            = local.resource_group_id
    tags                 = var.tags
    ignore_null_property = true
    retry                = null
    identity = var.identity != null ? {
      type = var.identity.type
      userAssignedIdentities = var.identity.identity_ids != null ? {
        for id in var.identity.identity_ids : id => {}
      } : null
    } : null
  }
  body = {
    extendedLocation = var.edge_zone != null && var.edge_zone != "" ? {
      name = var.edge_zone
      type = "EdgeZone"
    } : null
    plan = var.plan != null ? {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
    } : null
    zones = var.zone != null ? [var.zone] : null
    properties = merge(
      var.additional_capabilities != null ? {
        additionalCapabilities = {
          hibernationEnabled = var.additional_capabilities.hibernation_enabled
          ultraSSDEnabled    = var.additional_capabilities.ultra_ssd_enabled
        }
      } : {},
      var.gallery_application != null ? {
        applicationProfile = {
          galleryApplications = [
            for app in var.gallery_application : {
              packageReferenceId              = app.version_id
              enableAutomaticUpgrade          = app.automatic_upgrade_enabled
              configurationReference          = app.configuration_blob_uri
              order                           = app.order != null ? app.order : 0
              tags                            = app.tag
              treatFailureAsDeploymentFailure = app.treat_failure_as_deployment_failure_enabled
            }
          ]
        }
      } : {},
      {
        hardwareProfile = {
          vmSize = var.size
        }
        networkProfile = {
          networkInterfaces = [
            for i, id in var.network_interface_ids : {
              id = id
              properties = {
                primary = i == 0
              }
            }
          ]
        }
        priority = var.priority
        storageProfile = merge(
          {
            dataDisks = []
          },
          var.disk_controller_type != null ? {
            diskControllerType = var.disk_controller_type
          } : {},
          var.source_image_id != null ? {
            imageReference = local.is_community_gallery_image ? {
              communityGalleryImageId = var.source_image_id
              } : local.is_shared_gallery_image ? {
              sharedGalleryImageId = var.source_image_id
              } : {
              id = var.source_image_id
            }
          } : {},
          var.source_image_reference != null ? {
            imageReference = {
              offer     = var.source_image_reference.offer
              publisher = var.source_image_reference.publisher
              sku       = var.source_image_reference.sku
              version   = var.source_image_reference.version
            }
          } : {},
          var.os_disk != null ? {
            osDisk = merge(
              {
                caching = var.os_disk.caching
              },
              {
                managedDisk = merge(
                  var.os_managed_disk_id != null ? {
                    id = var.os_managed_disk_id
                    } : {
                    storageAccountType = var.os_disk.storage_account_type
                  },
                  var.os_managed_disk_id == null && local.effective_disk_encryption_set_id != null ? {
                    diskEncryptionSet = {
                      id = local.effective_disk_encryption_set_id
                    }
                  } : {},
                  var.os_managed_disk_id == null && (var.os_disk.security_encryption_type != null || var.os_disk.secure_vm_disk_encryption_set_id != null) ? {
                    securityProfile = merge(
                      var.os_disk.security_encryption_type != null ? {
                        securityEncryptionType = var.os_disk.security_encryption_type
                      } : {},
                      var.os_disk.secure_vm_disk_encryption_set_id != null ? {
                        diskEncryptionSet = {
                          id = var.os_disk.secure_vm_disk_encryption_set_id
                        }
                      } : {}
                    )
                  } : {}
                )
                createOption            = var.os_managed_disk_id != null ? "Attach" : "FromImage"
                diskSizeGB              = var.os_managed_disk_id == null && var.os_disk.disk_size_gb != null && var.os_disk.disk_size_gb > 0 ? var.os_disk.disk_size_gb : null
                name                    = var.os_managed_disk_id == null && var.os_disk.name != null && var.os_disk.name != "" ? var.os_disk.name : null
                writeAcceleratorEnabled = var.os_managed_disk_id == null ? var.os_disk.write_accelerator_enabled : null
                diffDiskSettings = var.os_managed_disk_id == null && var.os_disk.diff_disk_settings != null ? {
                  option    = var.os_disk.diff_disk_settings.option
                  placement = var.os_disk.diff_disk_settings.placement != null ? var.os_disk.diff_disk_settings.placement : "CacheDisk"
                } : null
                osType = var.os_managed_disk_id != null ? "Linux" : "Linux"
              }
            )
          } : {}
        )
        availabilitySet = var.availability_set_id != null ? {
          id = var.availability_set_id
        } : null
        capacityReservation = var.capacity_reservation_group_id != null ? {
          capacityReservationGroup = {
            id = var.capacity_reservation_group_id
          }
        } : null
        hostGroup = local.effective_dedicated_host_group_id != null ? {
          id = local.effective_dedicated_host_group_id
        } : null
        host = local.effective_dedicated_host_id != null ? {
          id = local.effective_dedicated_host_id
        } : null
        securityProfile = (var.encryption_at_host_enabled != null || var.vtpm_enabled != null || var.secure_boot_enabled != null || (var.os_disk != null && var.os_disk.security_encryption_type != null)) ? {
          encryptionAtHost = var.encryption_at_host_enabled
          securityType     = (var.os_disk != null && var.os_disk.security_encryption_type != null) ? "ConfidentialVM" : ((var.vtpm_enabled != null || var.secure_boot_enabled != null) ? "TrustedLaunch" : null)
          uefiSettings = (var.vtpm_enabled != null || var.secure_boot_enabled != null || (var.os_disk != null && var.os_disk.security_encryption_type != null)) ? {
            secureBootEnabled = var.secure_boot_enabled
            vTpmEnabled       = var.vtpm_enabled
          } : null
        } : null
        evictionPolicy       = var.eviction_policy
        extensionsTimeBudget = var.extensions_time_budget
        licenseType          = var.license_type
        proximityPlacementGroup = local.effective_proximity_placement_group_id != null ? {
          id = local.effective_proximity_placement_group_id
        } : null
        userData = var.user_data
        billingProfile = var.max_bid_price > 0 ? {
          maxPrice = var.max_bid_price
        } : null
        diagnosticsProfile = var.boot_diagnostics != null ? {
          bootDiagnostics = {
            enabled    = true
            storageUri = var.boot_diagnostics.storage_account_uri != null ? var.boot_diagnostics.storage_account_uri : ""
          }
          } : {
          bootDiagnostics = {
            enabled    = false
            storageUri = ""
          }
        }
      },
      var.virtual_machine_scale_set_id != null ? {
        virtualMachineScaleSet = {
          id = var.virtual_machine_scale_set_id
        }
      } : {},
      var.platform_fault_domain != -1 ? {
        platformFaultDomain = var.platform_fault_domain
      } : {},
      var.admin_username != null ? {
        osProfile = merge(
          {
            adminUsername            = var.admin_username
            allowExtensionOperations = var.allow_extension_operations
            computerName             = local.effective_computer_name
            linuxConfiguration = merge(
              var.admin_ssh_key != null ? {
                ssh = {
                  publicKeys = [
                    for key in local.effective_ssh_keys : {
                      keyData = key.public_key
                      path    = "/home/${key.username}/.ssh/authorized_keys"
                    }
                  ]
                }
              } : {},
              {
                disablePasswordAuthentication = var.disable_password_authentication
                provisionVMAgent              = var.provision_vm_agent
              },
              (var.bypass_platform_safety_checks_on_user_schedule_enabled || var.reboot_setting != null || var.patch_assessment_mode != null || var.patch_mode != "ImageDefault") ? {
                patchSettings = merge(
                  {
                    patchMode      = var.patch_mode != "ImageDefault" ? var.patch_mode : null
                    assessmentMode = var.patch_assessment_mode
                  },
                  (var.bypass_platform_safety_checks_on_user_schedule_enabled || var.reboot_setting != null) ? {
                    automaticByPlatformSettings = merge(
                      var.bypass_platform_safety_checks_on_user_schedule_enabled ? {
                        bypassPlatformSafetyChecksOnUserSchedule = true
                      } : {},
                      var.reboot_setting != null ? {
                        rebootSetting = var.reboot_setting
                      } : {}
                    )
                  } : {}
                )
              } : {},
              # Future tasks will add more merge elements here for other linuxConfiguration fields
            )
          },
          var.secret != null ? {
            secrets = [
              for secret_group in var.secret : {
                sourceVault = {
                  id = secret_group.key_vault_id
                }
                vaultCertificates = [
                  for cert in secret_group.certificate : {
                    certificateUrl = cert.url
                  }
                ]
              }
            ]
          } : {}
        )
      } : {},
      {
        scheduledEventsProfile = merge(
          {
            osImageNotificationProfile = var.os_image_notification != null ? {
              enable           = true
              notBeforeTimeout = var.os_image_notification.timeout
              } : {
              enable = false
            }
          },
          var.termination_notification != null ? {
            terminateNotificationProfile = {
              enable           = var.termination_notification.enabled
              notBeforeTimeout = var.termination_notification.timeout
            }
            } : {
            terminateNotificationProfile = {
              enable = false
            }
          }
        )
      }
    )
  }
  dedicated_host_group_id_should_suppress = (
    local.existing_dedicated_host_group_id != null &&
    local.desired_dedicated_host_group_id != null &&
    lower(local.existing_dedicated_host_group_id) == lower(local.desired_dedicated_host_group_id)
  )
  dedicated_host_id_should_suppress = (
    local.existing_dedicated_host_id != null &&
    local.desired_dedicated_host_id != null &&
    lower(local.existing_dedicated_host_id) == lower(local.desired_dedicated_host_id)
  )
  desired_admin_password               = var.admin_password
  desired_dedicated_host_group_id      = var.dedicated_host_group_id
  desired_dedicated_host_id            = var.dedicated_host_id
  desired_disk_encryption_set_id       = var.os_disk != null ? var.os_disk.disk_encryption_set_id : null
  desired_proximity_placement_group_id = var.proximity_placement_group_id
  disable_password_authentication      = coalesce(var.disable_password_authentication, true)
  disk_encryption_set_id_should_suppress = (
    local.existing_disk_encryption_set_id != null &&
    local.desired_disk_encryption_set_id != null &&
    lower(local.existing_disk_encryption_set_id) == lower(local.desired_disk_encryption_set_id)
  )
  effective_admin_password = local.admin_password_should_suppress ? coalesce(local.existing_admin_password, local.desired_admin_password) : local.desired_admin_password
  effective_computer_name = var.computer_name != null ? var.computer_name : (
    local.name_is_valid_computer_name ? var.name : null
  )
  effective_dedicated_host_group_id      = local.dedicated_host_group_id_should_suppress ? coalesce(local.existing_dedicated_host_group_id, local.desired_dedicated_host_group_id) : local.desired_dedicated_host_group_id
  effective_dedicated_host_id            = local.dedicated_host_id_should_suppress ? coalesce(local.existing_dedicated_host_id, local.desired_dedicated_host_id) : local.desired_dedicated_host_id
  effective_disk_encryption_set_id       = local.disk_encryption_set_id_should_suppress ? coalesce(local.existing_disk_encryption_set_id, local.desired_disk_encryption_set_id) : local.desired_disk_encryption_set_id
  effective_proximity_placement_group_id = local.proximity_placement_group_id_should_suppress ? coalesce(local.existing_proximity_placement_group_id, local.desired_proximity_placement_group_id) : local.desired_proximity_placement_group_id
  # For each SSH key, determine if we should suppress the diff
  effective_ssh_keys = var.admin_ssh_key != null ? [
    for key_input in var.admin_ssh_key : {
      username = key_input.username
      public_key = (
        # Check if we have existing keys for this username
        contains(keys(local.existing_ssh_keys_by_username), key_input.username) ? (
          # Normalize the new key
          lookup(local.normalize_ssh_key, "${key_input.username}_${key_input.public_key}", null) != null ? (
            # Check if this normalized key matches any existing key for this username
            contains([
              for existing_key in local.existing_ssh_keys_by_username[key_input.username] :
              join("", [for line in split("\n", replace(existing_key, "\r", "")) : trimspace(line)])
              ], local.normalize_ssh_key["${key_input.username}_${key_input.public_key}"]) ? (
              # Keys match, find and use the matching existing key to suppress diff
              [
                for existing_key in local.existing_ssh_keys_by_username[key_input.username] :
                existing_key if join("", [for line in split("\n", replace(existing_key, "\r", "")) : trimspace(line)]) == local.normalize_ssh_key["${key_input.username}_${key_input.public_key}"]
              ][0]
              ) : (
              # No match, use new key
              key_input.public_key
            )
            ) : (
            # Normalization failed, use new key
            key_input.public_key
          )
          ) : (
          # No existing keys for this username, use new key
          key_input.public_key
        )
      )
    }
  ] : null
  # DiffSuppressFunc logic for admin_password
  # The provider suppresses diff when old or new value equals "ignored-as-imported"
  existing_admin_password = local.should_read_existing_admin_password && data.azapi_resource.existing.exists ? try(data.azapi_resource.existing.output.properties.osProfile.adminPassword, null) : null
  # DiffSuppressFunc logic for dedicated_host_group_id
  # The provider suppresses diff when only case differs (suppress.CaseDifference)
  existing_dedicated_host_group_id = local.should_read_existing_dedicated_host_group_id && data.azapi_resource.existing.exists ? try(data.azapi_resource.existing.output.properties.hostGroup.id, null) : null
  # DiffSuppressFunc logic for dedicated_host_id
  # The provider suppresses diff when only case differs (suppress.CaseDifference)
  existing_dedicated_host_id = local.should_read_existing_dedicated_host_id && data.azapi_resource.existing.exists ? try(data.azapi_resource.existing.output.properties.host.id, null) : null
  # DiffSuppressFunc logic for os_disk.disk_encryption_set_id
  # The provider suppresses diff when only case differs (suppress.CaseDifference)
  existing_disk_encryption_set_id = local.should_read_existing_disk_encryption_set_id && data.azapi_resource.existing.exists ? try(data.azapi_resource.existing.output.properties.storageProfile.osDisk.managedDisk.diskEncryptionSet.id, null) : null
  # DiffSuppressFunc logic for proximity_placement_group_id
  # The provider suppresses diff when only case differs (suppress.CaseDifference)
  existing_proximity_placement_group_id = local.should_read_existing_proximity_placement_group_id && data.azapi_resource.existing.exists ? try(data.azapi_resource.existing.output.properties.proximityPlacementGroup.id, null) : null
  existing_ssh_keys                     = local.should_read_existing_admin_ssh_key && data.azapi_resource.existing.exists ? try(data.azapi_resource.existing.output.properties.osProfile.linuxConfiguration.ssh.publicKeys, null) : null
  existing_ssh_keys_by_username = local.existing_ssh_keys != null ? {
    for key in local.existing_ssh_keys : (
      # Parse username from path like "/home/username/.ssh/authorized_keys"
      try(regex("/home/([^/]+)/.ssh/authorized_keys", key.path)[0], null)
    ) => key.keyData... if try(regex("/home/([^/]+)/.ssh/authorized_keys", key.path)[0], null) != null
  } : {}
  # Detect image ID format based on provider's expandSourceImageReference logic
  is_community_gallery_image = var.source_image_id != null ? (
    can(regex("^/communityGalleries/[^/]+/images/", var.source_image_id))
  ) : false
  is_shared_gallery_image = var.source_image_id != null && !local.is_community_gallery_image ? (
    can(regex("^/sharedGalleries/[^/]+/images/", var.source_image_id))
  ) : false
  locks = []
  # computer_name defaults to VM name if not specified, but only if name is a valid computer_name
  # Provider validates: non-empty, max 64 chars, no leading underscore, no trailing period/dash, no special chars
  name_is_valid_computer_name = (
    length(trimspace(var.name)) > 0 &&
    length(var.name) <= 64 &&
    !startswith(var.name, "_") &&
    !endswith(var.name, ".") &&
    !endswith(var.name, "-") &&
    !can(regex("[\\\\/\"\\[\\]:|<>+=;,?*@&~!#$%^()_{}']", var.name))
  )
  # DiffSuppressFunc logic for admin_ssh_key.public_key
  # The provider normalizes SSH keys by removing heredoc markers, carriage returns, and whitespace
  normalize_ssh_key = { for key_input in(var.admin_ssh_key != null ? var.admin_ssh_key : []) : "${key_input.username}_${key_input.public_key}" => (
    # Step 1: Remove heredoc markers (prefix "<<~EOT" and suffix "EOT" only)
    # Step 2: Remove carriage returns
    # Step 3: Split by newlines, trim each line, and join
    join("", [for line in split("\n", replace(
      # Remove prefix and suffix if both present
      (startswith(key_input.public_key, "<<~EOT") && endswith(key_input.public_key, "EOT")) ?
      substr(key_input.public_key, 6, length(key_input.public_key) - 9) : # Remove <<~EOT (6 chars) and EOT (3 chars)
      key_input.public_key,
    "\r", "")) : trimspace(line)])
  ) }
  proximity_placement_group_id_should_suppress = (
    local.existing_proximity_placement_group_id != null &&
    local.desired_proximity_placement_group_id != null &&
    lower(local.existing_proximity_placement_group_id) == lower(local.desired_proximity_placement_group_id)
  )
  replace_triggers_external_values = {
    name                                     = { value = var.name }
    resource_group_id                        = { value = var.resource_group_id }
    location                                 = { value = var.location }
    admin_username                           = { value = var.admin_username }
    admin_password_version                   = { value = var.admin_password_version }
    availability_set_id                      = { value = var.availability_set_id }
    computer_name                            = { value = local.effective_computer_name }
    custom_data_version                      = { value = var.custom_data_version }
    disable_password_authentication          = { value = var.disable_password_authentication }
    edge_zone                                = { value = var.edge_zone }
    eviction_policy                          = { value = var.eviction_policy }
    priority                                 = { value = var.priority }
    provision_vm_agent                       = { value = var.provision_vm_agent }
    source_image_id                          = { value = var.source_image_id }
    source_image_reference                   = { value = var.source_image_reference }
    secure_boot_enabled                      = { value = var.secure_boot_enabled }
    vtpm_enabled                             = { value = var.vtpm_enabled }
    zone                                     = { value = var.zone }
    plan                                     = { value = var.plan }
    os_managed_disk_id                       = { value = var.os_managed_disk_id }
    os_disk_storage_account_type             = { value = var.os_disk != null ? var.os_disk.storage_account_type : null }
    os_disk_name                             = { value = var.os_disk != null ? var.os_disk.name : null }
    os_disk_secure_vm_disk_encryption_set_id = { value = var.os_disk != null ? var.os_disk.secure_vm_disk_encryption_set_id : null }
    os_disk_security_encryption_type         = { value = var.os_disk != null ? var.os_disk.security_encryption_type : null }
    os_disk_diff_disk_settings_option        = { value = var.os_disk != null && var.os_disk.diff_disk_settings != null ? var.os_disk.diff_disk_settings.option : null }
    os_disk_diff_disk_settings_placement     = { value = var.os_disk != null && var.os_disk.diff_disk_settings != null ? (var.os_disk.diff_disk_settings.placement != null ? var.os_disk.diff_disk_settings.placement : "CacheDisk") : null }
    admin_ssh_key                            = { value = var.admin_ssh_key }
    platform_fault_domain                    = { value = var.platform_fault_domain }
  }
  sensitive_body = {
    properties = merge(
      (var.admin_password != null && !local.disable_password_authentication) || var.custom_data != null ? {
        osProfile = merge(
          (var.admin_password != null && !local.disable_password_authentication) ? {
            adminPassword = local.effective_admin_password
          } : {},
          var.custom_data != null ? {
            customData = var.custom_data
          } : {}
        )
      } : {}
    )
  }
  sensitive_body_version = {
    "properties.osProfile.adminPassword" = try(tostring(var.admin_password_version), "null")
    "properties.osProfile.customData"    = try(tostring(var.custom_data_version), "null")
  }
  # Data source to read existing resource for DiffSuppressFunc logic
  should_read_existing_admin_password               = var.admin_password != null
  should_read_existing_admin_ssh_key                = var.admin_ssh_key != null
  should_read_existing_dedicated_host_group_id      = var.dedicated_host_group_id != null
  should_read_existing_dedicated_host_id            = var.dedicated_host_id != null
  should_read_existing_disk_encryption_set_id       = var.os_disk != null && var.os_disk.disk_encryption_set_id != null
  should_read_existing_proximity_placement_group_id = var.proximity_placement_group_id != null
}

data "azapi_resource" "existing" {
  name                   = var.name
  parent_id              = local.resource_group_id
  type                   = local.azapi_header.type
  ignore_not_found       = true
  response_export_values = ["*"]
}
