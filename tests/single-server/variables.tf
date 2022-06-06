variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable Azure resources."
  default     = {}
}

variable "prefix" {
  type    = string
  default = "binddns"
}

variable "location" {
  type    = string
  default = "east us"
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "dns_server_private_ip" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "binddnsadmin"
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_key_path" {
    type = string
    default = "/home/binddnsadmin/.ssh/authorized_keys"
}

variable "hostname" {
    type = string
    default = "binddns"
}

#------------------------------------------------------------------------------
# Custom Data (cloud-init) arguments
#------------------------------------------------------------------------------
variable "listen_on_cidrs" {
    type = list(string)
}

variable "forwarders" {
    type = list(string)
    default = ["8.8.8.8", "8.8.4.4", "168.63.129.16"]
}

variable "dns_zone" {
    type = string
}

variable "soa_username" {
    type = string
}

variable "a_record_servername" {
    type = string
}

variable "a_record_ip_address" {
    type = string 
}