terraform {
  required_version = ">= 1.3"
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = ">=1.229.1"
    }
  }
}
