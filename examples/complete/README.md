# Complete

Configuration in this directory create CEN, TR, VPC, Vswitches and other resources in `cn-hangzhou`.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >=1.229.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_complete"></a> [complete](#module\_complete) | ../../ | n/a |

## Resources

No resources.

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
| <a name="input_region"></a> [region](#input\_region) | The region of the resources. | `string` | `"cn-hangzhou"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | The config of VPCs and vSwitches. Subnets are used for creating the necessary business resources, while tr\_subnets are used for creating the network interfaces of the transit router (TR). | <pre>map(object({<br>    cidr_block = string<br>    subnets    = list(string)<br>    tr_subnets = list(string)<br>  }))</pre> | <pre>{<br>  "dev": {<br>    "cidr_block": "172.17.0.0/16",<br>    "subnets": [<br>      "172.17.0.0/24",<br>      "172.17.1.0/24"<br>    ],<br>    "tr_subnets": [<br>      "172.17.3.0/24",<br>      "172.17.4.0/24"<br>    ]<br>  },<br>  "dmz": {<br>    "cidr_block": "172.16.0.0/16",<br>    "subnets": [<br>      "172.16.0.0/24",<br>      "172.16.1.0/24"<br>    ],<br>    "tr_subnets": [<br>      "172.16.3.0/24",<br>      "172.16.4.0/24"<br>    ]<br>  },<br>  "prd": {<br>    "cidr_block": "172.18.0.0/16",<br>    "subnets": [<br>      "172.18.0.0/24",<br>      "172.18.1.0/24"<br>    ],<br>    "tr_subnets": [<br>      "172.18.3.0/24",<br>      "172.18.4.0/24"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The zone ID of vSwitches. At least two availability zones are required. | `list(string)` | <pre>[<br>  "cn-hangzhou-j",<br>  "cn-hangzhou-k"<br>]</pre> | no |

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