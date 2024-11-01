output "cen_instance_id" {
  value       = module.complete.cen_instance_id
  description = "The id of cen instance."
}

output "cen_transit_router_id" {
  value       = module.complete.cen_transit_router_id
  description = "The id of cen transit router."
}

output "vpc_ids" {
  value       = module.complete.vpc_ids
  description = "The id of vpcs."
}


output "tr_vswitch_ids" {
  value       = module.complete.tr_vswitch_ids
  description = "The id of tr vswitches."
}

output "vswitch_ids" {
  value       = module.complete.vswitch_ids
  description = "The id of vswitches."
}


output "security_group_ids" {
  value       = module.complete.security_group_ids
  description = "The id of security groups."
}


output "instance_ids" {
  value       = module.complete.instance_ids
  description = "The id of instances."
}


output "nat_gateway_id" {
  value       = module.complete.nat_gateway_id
  description = "The id of nat gateway."
}

output "eip_id" {
  value       = module.complete.eip_id
  description = "The id of eip."
}

output "eip_ip" {
  value       = module.complete.eip_ip
  description = "The ip address of eip."
}

output "nlb_load_balancer_id" {
  value       = module.complete.nlb_load_balancer_id
  description = "The id of nlb load balancer."
}

output "nlb_server_group_id" {
  value       = module.complete.nlb_server_group_id
  description = "The id of nlb server group."
}

output "nlb_listener_id" {
  value       = module.complete.nlb_listener_id
  description = "The id of nlb listener."
}
