terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.9.0"
    }
  }
}

provider "azurerm" {
  environment = "public"
  features {}
}


module "binddns" {
  source = "../.."

  # --- Common --- #
  common_tags = var.common_tags
  prefix      = var.prefix
  location    = var.location

  # --- DNS Server --- #
  resource_group_name   = var.resource_group_name
  subnet_id             = var.subnet_id
  dns_server_private_ip = var.dns_server_private_ip
  admin_username        = var.admin_username
  ssh_public_key        = var.ssh_public_key
  ssh_key_path          = var.ssh_key_path

  # --- DNS Configuration --- #
  listen_on_cidrs     = var.listen_on_cidrs
  forwarders          = var.forwarders
  dns_zone            = var.dns_zone
  soa_username        = var.soa_username
  a_record_ip_address = var.a_record_ip_address
  a_record_servername = var.a_record_servername
  hostname            = var.hostname
}