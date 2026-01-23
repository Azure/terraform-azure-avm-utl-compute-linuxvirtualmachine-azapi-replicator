package Azure_Proactive_Resiliency_Library_v2

import rego.v1

exception contains rules if {
  rules = [
      "mission_critical_virtual_machine_should_use_premium_or_ultra_disks", 
      "mission_critical_virtual_machine_should_use_zone",
      "migrate_vm_using_availability_sets_to_vmss_flex"
  ]
}