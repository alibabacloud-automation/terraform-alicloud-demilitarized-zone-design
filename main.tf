# CEN & TR
resource "alicloud_cen_instance" "default" {
  cen_instance_name = var.cen_name
  protection_level  = "REDUCED"
  resource_group_id = var.resource_group_id
  tags              = var.tags
}

data "alicloud_regions" "this" {
  current = true
}

resource "alicloud_cen_transit_router" "default" {
  transit_router_name = "${var.cen_name}-${data.alicloud_regions.this.regions[0].id}"
  cen_id              = alicloud_cen_instance.default.id
  tags                = var.tags
}

# VPC & TR_Vswitches
locals {
  vpc_tr_subnets = {
    for k, v in var.vpcs : k => {
      vpc_name   = "${k}-vpc"
      cidr_block = v.cidr_block
      tr_subnets = [
        for i, subnet in v.tr_subnets : {
          vswitch_name = "${k}-tr-${i + 1}"
          cidr_block   = subnet
          zone_id      = var.zones[i]
        }
      ]
    }
  }
}

module "tr-vpc" {
  source  = "alibabacloud-automation/hybrid-cloud-network/alicloud//modules/vpc"
  version = "1.1.0"

  for_each = local.vpc_tr_subnets

  cen_instance_id       = alicloud_cen_instance.default.id
  cen_transit_router_id = alicloud_cen_transit_router.default.transit_router_id

  vpc = {
    cidr_block = each.value.cidr_block
    vpc_name   = each.value.vpc_name
  }
  vswitches = each.value.tr_subnets
}


# alicloud_vswitch
locals {
  vswitch_configs = {
    for item in flatten([
      for k, v in var.vpcs : [
        for i, subnet in v.subnets : {
          vswitch_name = "${k}-subnet-${i + 1}"
          cidr         = subnet
          zone_id      = var.zones[i]
          vpc_id       = module.tr-vpc[k].vpc_id
        }
      ]
    ]) : item.vswitch_name => item
  }
}

resource "alicloud_vswitch" "vswitch" {
  for_each = local.vswitch_configs

  vpc_id       = each.value.vpc_id
  cidr_block   = each.value.cidr
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
  tags         = var.tags
}


# alicloud_security_group & alicloud_security_group_rule
resource "alicloud_security_group" "vpc_security_groups" {
  for_each = var.vpcs

  name              = "${each.key}-security-group"
  vpc_id            = module.tr-vpc[each.key].vpc_id
  resource_group_id = var.resource_group_id
  tags              = var.tags
}

locals {
  security_group_rule_name = toset(flatten([
    for k, v in var.vpcs : [
      for protocol in ["http", "https", "ssh", "icmp"] : "${k}-${protocol}"
    ]
  ]))
  protocol_map = {
    http  = "tcp"
    https = "tcp"
    ssh   = "tcp"
    icmp  = "icmp"
  }
  port_map = {
    http  = "80/80"
    https = "443/443"
    ssh   = "22/22"
    icmp  = "-1/-1"
  }
}


resource "alicloud_security_group_rule" "vpc_security_group_rules" {
  for_each = local.security_group_rule_name

  type              = "ingress"
  ip_protocol       = local.protocol_map[split("-", each.key)[1]]
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = local.port_map[split("-", each.key)[1]]
  priority          = 1
  security_group_id = alicloud_security_group.vpc_security_groups[split("-", each.key)[0]].id
  cidr_ip           = "0.0.0.0/0"
}


# alicloud_instance
locals {
  instance_configs = {
    for item in flatten([
      for k, v in var.vpcs : [
        for i, subnet in v.subnets : {
          name        = "${k}-instance-${i + 1}"
          subnet_name = "${k}-subnet-${i + 1}"
          zone_id     = alicloud_vswitch.vswitch["${k}-subnet-${i + 1}"].zone_id
          vswitch_id  = alicloud_vswitch.vswitch["${k}-subnet-${i + 1}"].id
          sg_id       = alicloud_security_group.vpc_security_groups[k].id
        } if k == "dev" || k == "prd"
      ]
    ]) : "${item.subnet_name}-${"instance"}" => item
  }
}

resource "alicloud_instance" "instance" {
  for_each = local.instance_configs

  availability_zone          = each.value.zone_id
  security_groups            = [each.value.sg_id]
  instance_type              = var.instance_config.instance_type
  system_disk_category       = var.instance_config.system_disk_category
  image_id                   = var.instance_config.image_id
  instance_name              = each.value.name
  vswitch_id                 = each.value.vswitch_id
  password                   = var.instance_config.password
  internet_max_bandwidth_out = var.instance_config.internet_max_bandwidth_out
  resource_group_id          = var.resource_group_id
  tags                       = var.tags
}



data "alicloud_cen_transit_router_route_tables" "this" {
  transit_router_id               = alicloud_cen_transit_router.default.transit_router_id
  transit_router_route_table_type = "System"
}

resource "alicloud_cen_transit_router_route_entry" "example" {
  transit_router_route_table_id                     = data.alicloud_cen_transit_router_route_tables.this.tables[0].transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = "0.0.0.0/0"
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_next_hop_id            = module.tr-vpc["dmz"].tr_vpc_attachment_id
}


module "nat-gateway" {
  source  = "terraform-alicloud-modules/nat-gateway/alicloud"
  version = "1.5.0"

  # alicloud_nat_gateway
  vpc_id       = module.tr-vpc["dmz"].vpc_id
  vswitch_id   = alicloud_vswitch.vswitch["dmz-subnet-1"].id
  name         = "dmz-${var.nat_gateway_config.name_suffix}"
  payment_type = var.nat_gateway_config.payment_type
  nat_type     = var.nat_gateway_config.nat_type

  # alicloud_eip_address
  create_eip               = true
  eip_name                 = var.eip_address_config.name
  eip_isp                  = var.eip_address_config.isp
  eip_netmode              = var.eip_address_config.netmode
  eip_bandwidth            = var.eip_address_config.bandwidth
  eip_instance_charge_type = var.eip_address_config.instance_charge_type
}


resource "alicloud_snat_entry" "dev" {
  snat_table_id = module.nat-gateway.this_snat_table_id
  source_cidr   = var.vpcs.dev.cidr_block
  snat_ip       = module.nat-gateway.this_eip_ips[0]
}


resource "alicloud_nlb_load_balancer" "default" {
  load_balancer_name = "dmz-${var.nlb_load_balancer_config.address_ip_version}"
  load_balancer_type = var.nlb_load_balancer_config.load_balancer_type
  address_type       = var.nlb_load_balancer_config.address_type
  address_ip_version = var.nlb_load_balancer_config.address_ip_version
  vpc_id             = module.tr-vpc["dmz"].vpc_id
  zone_mappings {
    vswitch_id = alicloud_vswitch.vswitch["dmz-subnet-1"].id
    zone_id    = alicloud_vswitch.vswitch["dmz-subnet-1"].zone_id
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.vswitch["dmz-subnet-2"].id
    zone_id    = alicloud_vswitch.vswitch["dmz-subnet-2"].zone_id
  }
  resource_group_id = var.resource_group_id
  tags              = var.tags
}

resource "alicloud_nlb_server_group" "default" {
  server_group_name        = "prd-${var.nlb_server_group_config.server_group_name_suffix}"
  server_group_type        = var.nlb_server_group_config.server_group_type
  vpc_id                   = module.tr-vpc["dmz"].vpc_id
  scheduler                = var.nlb_server_group_config.scheduler
  protocol                 = var.nlb_server_group_config.protocol
  connection_drain_enabled = var.nlb_server_group_config.connection_drain_enabled
  connection_drain_timeout = var.nlb_server_group_config.connection_drain_timeout
  address_ip_version       = var.nlb_server_group_config.address_ip_version
  resource_group_id        = var.resource_group_id
  tags                     = var.tags
  dynamic "health_check" {
    for_each = var.nlb_server_group_health_check
    content {
      health_check_enabled         = health_check.value.health_check_enabled
      health_check_type            = health_check.value.health_check_type
      health_check_connect_port    = health_check.value.health_check_connect_port
      healthy_threshold            = health_check.value.healthy_threshold
      unhealthy_threshold          = health_check.value.unhealthy_threshold
      health_check_connect_timeout = health_check.value.health_check_connect_timeout
      health_check_interval        = health_check.value.health_check_interval
      http_check_method            = health_check.value.http_check_method
      health_check_http_code       = health_check.value.health_check_http_code
    }
  }
}


resource "alicloud_nlb_server_group_server_attachment" "prd_1" {
  server_type     = var.nlb_server_group_server_attachment_config.server_type
  server_id       = alicloud_instance.instance["prd-subnet-1-instance"].primary_ip_address
  server_ip       = alicloud_instance.instance["prd-subnet-1-instance"].primary_ip_address
  port            = var.nlb_server_group_server_attachment_config.port
  server_group_id = alicloud_nlb_server_group.default.id
  weight          = var.nlb_server_group_server_attachment_config.weight
}

resource "alicloud_nlb_server_group_server_attachment" "prd_2" {
  server_type     = var.nlb_server_group_server_attachment_config.server_type
  server_id       = alicloud_instance.instance["prd-subnet-2-instance"].primary_ip_address
  server_ip       = alicloud_instance.instance["prd-subnet-2-instance"].primary_ip_address
  port            = var.nlb_server_group_server_attachment_config.port
  server_group_id = alicloud_nlb_server_group.default.id
  weight          = var.nlb_server_group_server_attachment_config.weight
}


resource "alicloud_nlb_listener" "default" {
  listener_protocol      = var.nlb_listener_config.listener_protocol
  listener_port          = var.nlb_listener_config.listener_port
  load_balancer_id       = alicloud_nlb_load_balancer.default.id
  server_group_id        = alicloud_nlb_server_group.default.id
  idle_timeout           = var.nlb_listener_config.idle_timeout
  proxy_protocol_enabled = var.nlb_listener_config.proxy_protocol_enabled
  cps                    = var.nlb_listener_config.cps
  mss                    = var.nlb_listener_config.mss
  tags                   = var.tags
}
