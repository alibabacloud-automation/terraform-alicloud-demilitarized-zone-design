Terraform module to build unified public network entry and exit point on Alibaba Cloud

terraform-alicloud-demilitarized-zone-design
======================================

[English](https://github.com/alibabacloud-automation/terraform-alicloud-demilitarized-zone-design/blob/main/README.md) | 简体中文

云上统一公网出入口(DMZ)是指在阿里云环境中创建一个新的虚拟私有云(VPC)，用作外部互联网（非信任区域）与企业内部网络（信任区域）之间的缓冲区。这一设计不仅实现了对外部互联网接入与出口资源的集中管理，还便于构建能够处理高并发、大流量的应用接入网关，并有效地管理和优化公网带宽的使用。此外，通过与各类安全产品的整合，统一公网出入口的设计能够显著增强对云上内网的安全防护，确保企业的数据和应用得到全面而有效的保护。

架构图:

![image](https://raw.githubusercontent.com/alibabacloud-automation/terraform-alicloud-demilitarized-zone-design/main/scripts/diagramCN.png)

## 用法

在杭州区域创建资源

```hcl
provider "alicloud" {
  region = "cn-hangzhou"
}

module "complete" {
  source = "alibabacloud-automation/demilitarized-zone-design/alicloud"

  vpcs = {
    dmz = {
      cidr_block = "172.16.0.0/16",
      subnets    = ["172.16.0.0/24", "172.16.1.0/24"],
      tr_subnets = ["172.16.3.0/24", "172.16.4.0/24"],
    }
    dev = {
      cidr_block = "172.17.0.0/16",
      subnets    = ["172.17.0.0/24", "172.17.1.0/24"],
      tr_subnets = ["172.17.3.0/24", "172.17.4.0/24"],
    }
    prd = {
      cidr_block = "172.18.0.0/16",
      subnets    = ["172.18.0.0/24", "172.18.1.0/24"],
      tr_subnets = ["172.18.3.0/24", "172.18.4.0/24"],
    }
  }
  zones = ["cn-hangzhou-j", "cn-hangzhou-k"]
}
```


## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-demilitarized-zone-design/tree/main/examples/complete)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >=1.229.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >=1.229.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nat-gateway"></a> [nat-gateway](#module\_nat-gateway) | terraform-alicloud-modules/nat-gateway/alicloud | 1.5.0 |
| <a name="module_tr-vpc"></a> [tr-vpc](#module\_tr-vpc) | alibabacloud-automation/hybrid-cloud-network/alicloud//modules/vpc | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [alicloud_cen_instance.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/cen_instance) | resource |
| [alicloud_cen_transit_router.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/cen_transit_router) | resource |
| [alicloud_cen_transit_router_route_entry.example](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource |
| [alicloud_instance.instance](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_nlb_listener.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/nlb_listener) | resource |
| [alicloud_nlb_load_balancer.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/nlb_load_balancer) | resource |
| [alicloud_nlb_server_group.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/nlb_server_group) | resource |
| [alicloud_nlb_server_group_server_attachment.prd_1](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/nlb_server_group_server_attachment) | resource |
| [alicloud_nlb_server_group_server_attachment.prd_2](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/nlb_server_group_server_attachment) | resource |
| [alicloud_security_group.vpc_security_groups](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.vpc_security_group_rules](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_snat_entry.dev](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/snat_entry) | resource |
| [alicloud_vswitch.vswitch](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_cen_transit_router_route_tables.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/data-sources/cen_transit_router_route_tables) | data source |
| [alicloud_regions.this](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cen_name"></a> [cen\_name](#input\_cen\_name) | The name of cen instance and TR | `string` | `"WA-DESIGN"` | no |
| <a name="input_eip_address_config"></a> [eip\_address\_config](#input\_eip\_address\_config) | The config of eip\_address. | <pre>object({<br>    name                 = optional(string, "nat-eip")<br>    isp                  = optional(string, "BGP")<br>    netmode              = optional(string, "public")<br>    bandwidth            = optional(string, "10")<br>    instance_charge_type = optional(string, "PostPaid")<br>  })</pre> | `{}` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | The config of ecs instance. | <pre>object({<br>    instance_type              = optional(string, "ecs.c7.large")<br>    system_disk_category       = string<br>    image_id                   = optional(string, "aliyun_3_x64_20G_alibase_20240819.vhd")<br>    internet_max_bandwidth_out = optional(number, 0)<br>    password                   = string<br>  })</pre> | <pre>{<br>  "password": "WaDesign.",<br>  "system_disk_category": "cloud_essd"<br>}</pre> | no |
| <a name="input_nat_gateway_config"></a> [nat\_gateway\_config](#input\_nat\_gateway\_config) | The config of nat gateway. | <pre>object({<br>    name_suffix  = optional(string, "nat")<br>    payment_type = optional(string, "PayAsYouGo")<br>    nat_type     = optional(string, "Enhanced")<br>  })</pre> | `{}` | no |
| <a name="input_nlb_listener_config"></a> [nlb\_listener\_config](#input\_nlb\_listener\_config) | The config of nlb\_listener. Create a TCP port 80 listener. | <pre>object({<br>    listener_protocol      = optional(string, "TCP")<br>    listener_port          = optional(string, "80")<br>    idle_timeout           = optional(string, "900")<br>    proxy_protocol_enabled = optional(string, "true")<br>    cps                    = optional(string, "10000")<br>    mss                    = optional(string, "0")<br>  })</pre> | `{}` | no |
| <a name="input_nlb_load_balancer_config"></a> [nlb\_load\_balancer\_config](#input\_nlb\_load\_balancer\_config) | The config of nlb\_load\_balancer. Create an IPv4 public network type NLB load balancer. | <pre>object({<br>    load_balancer_name_suffix = optional(string, "nlb")<br>    load_balancer_type        = optional(string, "Network")<br>    address_type              = optional(string, "Internet")<br>    address_ip_version        = optional(string, "Ipv4")<br>  })</pre> | `{}` | no |
| <a name="input_nlb_server_group_config"></a> [nlb\_server\_group\_config](#input\_nlb\_server\_group\_config) | The config of nlb\_server\_group. Create an IP-type server group for mounting ECS instances from the PRD VPC in the DMZ area as the backend of the NLB. | <pre>object({<br>    server_group_name_suffix = optional(string, "server-group")<br>    server_group_type        = optional(string, "Ip")<br>    scheduler                = optional(string, "Wrr")<br>    protocol                 = optional(string, "TCP")<br>    connection_drain_enabled = optional(bool, "true")<br>    connection_drain_timeout = optional(number, 60)<br>    address_ip_version       = optional(string, "Ipv4")<br>  })</pre> | `{}` | no |
| <a name="input_nlb_server_group_health_check"></a> [nlb\_server\_group\_health\_check](#input\_nlb\_server\_group\_health\_check) | The config of nlb\_server\_group\_health\_check. | <pre>list(object({<br>    health_check_enabled         = optional(bool, true)<br>    health_check_type            = optional(string, "TCP")<br>    health_check_connect_port    = optional(number, 0)<br>    healthy_threshold            = optional(number, 2)<br>    unhealthy_threshold          = optional(number, 2)<br>    health_check_connect_timeout = optional(number, 5)<br>    health_check_interval        = optional(number, 10)<br>    http_check_method            = optional(string, "GET")<br>    health_check_http_code       = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])<br>  }))</pre> | <pre>[<br>  {<br>    "health_check_connect_port": 0,<br>    "health_check_connect_timeout": 5,<br>    "health_check_enabled": true,<br>    "health_check_http_code": [<br>      "http_2xx",<br>      "http_3xx",<br>      "http_4xx"<br>    ],<br>    "health_check_interval": 10,<br>    "health_check_type": "TCP",<br>    "healthy_threshold": 2,<br>    "http_check_method": "GET",<br>    "unhealthy_threshold": 2<br>  }<br>]</pre> | no |
| <a name="input_nlb_server_group_server_attachment_config"></a> [nlb\_server\_group\_server\_attachment\_config](#input\_nlb\_server\_group\_server\_attachment\_config) | The config of nlb\_server\_group\_server\_attachment. | <pre>object({<br>    server_type = string<br>    port        = optional(number, 80)<br>    weight      = optional(number, 100)<br>  })</pre> | <pre>{<br>  "server_type": "Ip"<br>}</pre> | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of resource group. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags of resources. | `any` | `{}` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | The config of VPCs and vSwitches. Subnets are used for creating the necessary business resources, while tr\_subnets are used for creating the network interfaces of the transit router (TR). | <pre>map(object({<br>    cidr_block = string<br>    subnets    = list(string)<br>    tr_subnets = list(string)<br>  }))</pre> | <pre>{<br>  "dev": {<br>    "cidr_block": "172.17.0.0/16",<br>    "subnets": [<br>      "172.17.0.0/24",<br>      "172.17.1.0/24"<br>    ],<br>    "tr_subnets": [<br>      "172.17.3.0/24",<br>      "172.17.4.0/24"<br>    ]<br>  },<br>  "dmz": {<br>    "cidr_block": "172.16.0.0/16",<br>    "subnets": [<br>      "172.16.0.0/24",<br>      "172.16.1.0/24"<br>    ],<br>    "tr_subnets": [<br>      "172.16.3.0/24",<br>      "172.16.4.0/24"<br>    ]<br>  },<br>  "prd": {<br>    "cidr_block": "172.18.0.0/16",<br>    "subnets": [<br>      "172.18.0.0/24",<br>      "172.18.1.0/24"<br>    ],<br>    "tr_subnets": [<br>      "172.18.3.0/24",<br>      "172.18.4.0/24"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The zone ID of vSwitches. At least two availability zones are required. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cen_instance_id"></a> [cen\_instance\_id](#output\_cen\_instance\_id) | The id of cen instance. |
| <a name="output_cen_transit_router_id"></a> [cen\_transit\_router\_id](#output\_cen\_transit\_router\_id) | The id of cen transit router. |
| <a name="output_eip_id"></a> [eip\_id](#output\_eip\_id) | The id of eip. |
| <a name="output_eip_ip"></a> [eip\_ip](#output\_eip\_ip) | The ip address of eip. |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | The id of instances. |
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | The id of nat gateway. |
| <a name="output_nlb_listener_id"></a> [nlb\_listener\_id](#output\_nlb\_listener\_id) | The id of nlb listener. |
| <a name="output_nlb_load_balancer_id"></a> [nlb\_load\_balancer\_id](#output\_nlb\_load\_balancer\_id) | The id of nlb load balancer. |
| <a name="output_nlb_server_group_id"></a> [nlb\_server\_group\_id](#output\_nlb\_server\_group\_id) | The id of nlb server group. |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | The id of security groups. |
| <a name="output_tr_vswitch_ids"></a> [tr\_vswitch\_ids](#output\_tr\_vswitch\_ids) | The id of tr vswitches. |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | The id of vpcs. |
| <a name="output_vswitch_ids"></a> [vswitch\_ids](#output\_vswitch\_ids) | The id of vswitches. |
<!-- END_TF_DOCS -->

## 提交问题

如果在使用该 Terraform Module 的过程中有任何问题，可以直接创建一个 [Provider Issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new)，我们将根据问题描述提供解决方案。

**注意:** 不建议在该 Module 仓库中直接提交 Issue。

## 作者

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## 许可

MIT Licensed. See LICENSE for full details.

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
