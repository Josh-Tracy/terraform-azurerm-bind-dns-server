variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable Azure resources."
  default     = {}
}

variable "prefix" {
  description = "Friendly name prefix for unique Azure resource naming."
  type        = string
  default     = "binddns"
}

variable "location" {
  description = "Azure region to deploy into."
  type        = string
  default     = "east us"
}

variable "resource_group_name" {
  description = "The name of an existing resource group to deploy into."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy the VM into."
  type        = string
}

variable "dns_server_private_ip" {
  description = "A private IP address to assign to the DNS VM."
  type        = string
}

variable "admin_username" {
  description = "The admin username used for SSH."
  type        = string
  default     = "binddnsadmin"
}

variable "ssh_public_key" {
  description = "The public key to be placed onto the VM."
  type        = string
}

variable "ssh_key_path" {
  description = "The path on the VM to place the SSH public key."
  type        = string
  default     = "/home/binddnsadmin/.ssh/authorized_keys"
}

variable "hostname" {
  description = "The hostname of the VM."
  type        = string
  default     = "binddns"
}

#------------------------------------------------------------------------------
# Custom Data (cloud-init) arguments
#------------------------------------------------------------------------------
variable "listen_on_cidrs" {
  description = "A list of CIDR addresses that the DNS server will listen on for requests. Requests from CIDR ranges not listed will be ignored."
  type        = list(string)
}

variable "forwarders" {
  description = "A list of DNS servers to forward requests to."
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4", "168.63.129.16"]
}

variable "dns_zone" {
  description = "The domain name of a DNS zone you wish to create records within. Example: domain.com"
  type        = string
}

variable "soa_username" {
  description = "The first half of the email address for the owner of this domain. An example of this would be root if the owner was root@example.com."
  type        = string
}

variable "a_record_servername" {
  description = "The FQDN of a host you wish to create an A record for."
  type        = string
}

variable "a_record_ip_address" {
  description = "The IP address for the server you are creating an A record for."
  type        = string
}