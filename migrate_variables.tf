# New variables only

variable "resource_group_id" {
  type        = string
  description = "(Required) The ID of the Resource Group in which the Linux Virtual Machine should exist. Changing this forces a new resource to be created."
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/[a-fA-F0-9-]+/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "resource_group_id must be a valid Azure Resource Group ID in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}"
  }
}

variable "admin_password_version" {
  type        = number
  default     = null
  description = "(Optional) Version tracking for admin_password. Must be set when admin_password is provided."

  validation {
    condition     = var.admin_password == null || var.admin_password_version != null
    error_message = "When admin_password is set, admin_password_version must also be set."
  }
}

variable "custom_data_version" {
  type        = number
  default     = null
  description = "(Optional) Version tracking for custom_data. Must be set when custom_data is provided."

  validation {
    condition     = var.custom_data == null || var.custom_data_version != null
    error_message = "When custom_data is set, custom_data_version must also be set."
  }
}
