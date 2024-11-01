output "cen_instance_id" {
  value       = alicloud_cen_instance.default.id
  description = "The id of cen instance."
}

output "cen_transit_router_id" {
  value       = alicloud_cen_transit_router.default.transit_router_id
  description = "The id of cen transit router."
}

output "vpc_ids" {
  value       = [for i, tr-vpc in module.tr-vpc : tr-vpc.vpc_id]
  description = "The id of vpcs."
}


output "tr_vswitch_ids" {
  value       = [for i, tr-vpc in module.tr-vpc : tr-vpc.vswitch_ids]
  description = "The id of tr vswitches."
}

output "vswitch_ids" {
  value       = [for i, vswitch in alicloud_vswitch.vswitch : vswitch.id]
  description = "The id of vswitches."
}


output "security_group_ids" {
  value       = [for i, security_group in alicloud_security_group.vpc_security_groups : security_group.id]
  description = "The id of security groups."
}


output "instance_ids" {
  value       = [for i, instance in alicloud_instance.instance : instance.id]
  description = "The id of instances."
}


output "nat_gateway_id" {
  value       = module.nat-gateway.this_nat_gateway_id
  description = "The id of nat gateway."
}

output "eip_id" {
  value       = module.nat-gateway.this_eip_ids
  description = "The id of eip."
}

output "eip_ip" {
  value       = module.nat-gateway.this_eip_ips
  description = "The ip address of eip."
}

output "nlb_load_balancer_id" {
  value       = alicloud_nlb_load_balancer.default.id
  description = "The id of nlb load balancer."
}

output "nlb_server_group_id" {
  value       = alicloud_nlb_server_group.default.id
  description = "The id of nlb server group."
}

output "nlb_listener_id" {
  value       = alicloud_nlb_listener.default.id
  description = "The id of nlb listener."
}
