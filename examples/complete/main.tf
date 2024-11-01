provider "alicloud" {
  region = var.region
}

module "complete" {
  source = "../../"

  cen_name = var.cen_name

  vpcs  = var.vpcs
  zones = var.zones

  instance_config = var.instance_config

  nat_gateway_config = var.nat_gateway_config
  eip_address_config = var.eip_address_config

  nlb_load_balancer_config                  = var.nlb_load_balancer_config
  nlb_server_group_config                   = var.nlb_server_group_config
  nlb_server_group_health_check             = var.nlb_server_group_health_check
  nlb_server_group_server_attachment_config = var.nlb_server_group_server_attachment_config
  nlb_listener_config                       = var.nlb_listener_config

  tags = var.tags
}
