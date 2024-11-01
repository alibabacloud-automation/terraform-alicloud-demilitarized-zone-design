variable "region" {
  type        = string
  description = "The region of the resources."
  default     = "cn-hangzhou"
}

variable "zones" {
  type        = list(string)
  default     = ["cn-hangzhou-j", "cn-hangzhou-k"]
  description = "The zone ID of vSwitches. At least two availability zones are required."
}


variable "cen_name" {
  type        = string
  description = "The name of cen instance and TR"
  default     = "WA-DESIGN"
}

# vpc & vswitch
variable "vpcs" {
  type = map(object({
    cidr_block = string
    subnets    = list(string)
    tr_subnets = list(string)
  }))
  default = {
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
  description = "The config of VPCs and vSwitches. Subnets are used for creating the necessary business resources, while tr_subnets are used for creating the network interfaces of the transit router (TR)."
}


# ecs instance
variable "instance_config" {
  type = object({
    instance_type              = optional(string, "ecs.c7.large")
    system_disk_category       = string
    image_id                   = optional(string, "aliyun_3_x64_20G_alibase_20240819.vhd")
    internet_max_bandwidth_out = optional(number, 0)
    password                   = string
  })
  default = {
    system_disk_category = "cloud_essd"
    password             = "WaDesign."
  }
  description = "The config of ecs instance."
}

variable "nat_gateway_config" {
  type = object({
    name_suffix  = optional(string, "nat")
    payment_type = optional(string, "PayAsYouGo")
    nat_type     = optional(string, "Enhanced")
  })
  default     = {}
  description = "The config of nat gateway."
}

variable "eip_address_config" {
  type = object({
    name                 = optional(string, "nat-eip")
    isp                  = optional(string, "BGP")
    netmode              = optional(string, "public")
    bandwidth            = optional(string, "10")
    instance_charge_type = optional(string, "PostPaid")
  })
  default     = {}
  description = "The config of eip_address."

}

variable "nlb_load_balancer_config" {
  type = object({
    load_balancer_name_suffix = optional(string, "nlb")
    load_balancer_type        = optional(string, "Network")
    address_type              = optional(string, "Internet")
    address_ip_version        = optional(string, "Ipv4")
  })
  default     = {}
  description = "The config of nlb_load_balancer. Create an IPv4 public network type NLB load balancer."
}

variable "nlb_server_group_config" {
  type = object({
    server_group_name_suffix = optional(string, "server-group")
    server_group_type        = optional(string, "Ip")
    scheduler                = optional(string, "Wrr")
    protocol                 = optional(string, "TCP")
    connection_drain_enabled = optional(bool, "true")
    connection_drain_timeout = optional(number, 60)
    address_ip_version       = optional(string, "Ipv4")
  })

  default     = {}
  description = "The config of nlb_server_group. Create an IP-type server group for mounting ECS instances from the PRD VPC in the DMZ area as the backend of the NLB."
}


variable "nlb_server_group_health_check" {
  type = list(object({
    health_check_enabled         = optional(bool, true)
    health_check_type            = optional(string, "TCP")
    health_check_connect_port    = optional(number, 0)
    healthy_threshold            = optional(number, 2)
    unhealthy_threshold          = optional(number, 2)
    health_check_connect_timeout = optional(number, 5)
    health_check_interval        = optional(number, 10)
    http_check_method            = optional(string, "GET")
    health_check_http_code       = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])
  }))
  default = [{
    health_check_enabled         = true
    health_check_type            = "TCP"
    health_check_connect_port    = 0
    healthy_threshold            = 2
    unhealthy_threshold          = 2
    health_check_connect_timeout = 5
    health_check_interval        = 10
    http_check_method            = "GET"
    health_check_http_code       = ["http_2xx", "http_3xx", "http_4xx"]
  }]
  description = "The config of nlb_server_group_health_check."
}

variable "nlb_server_group_server_attachment_config" {
  type = object({
    server_type = string
    port        = optional(number, 80)
    weight      = optional(number, 100)
  })

  default = {
    server_type = "Ip"
  }
  description = "The config of nlb_server_group_server_attachment."
}

variable "nlb_listener_config" {
  type = object({
    listener_protocol      = optional(string, "TCP")
    listener_port          = optional(string, "80")
    idle_timeout           = optional(string, "900")
    proxy_protocol_enabled = optional(string, "true")
    cps                    = optional(string, "10000")
    mss                    = optional(string, "0")
  })
  default     = {}
  description = "The config of nlb_listener. Create a TCP port 80 listener."
}


variable "tags" {
  type = any
  default = {
    Created = "Terraform"
  }
  description = "The tags of resources."
}
