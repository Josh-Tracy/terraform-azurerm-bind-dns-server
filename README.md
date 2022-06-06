# terraform-azurerm-bind-dns-server

## Background
This module deploys an ubuntu VM into the specified Azure VNET and subnet, installs Bind9, and configures the bind9 server to create a DNS forwarder and lookup zone based on the inputs provided.
<p>&nbsp;</p>

When you are using Azure-provided name resolution, Azure Dynamic Host Configuration Protocol (DHCP) provides an internal DNS suffix (.internal.cloudapp.net) to each VM. This suffix enables host name resolution because the host name records are in the internal.cloudapp.net zone. When you are using your own name resolution solution, this suffix is not supplied to VMs because it interferes with other DNS architectures (like domain-joined scenarios). Instead, Azure provides a non-functioning placeholder (reddog.microsoft.com) which can be viewed in the `/etc/resolv.conf` file.

>Note: See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances
<p>&nbsp;</p>

## Prerequisites
- Routing may need to be configured based on the location of the DNS server relative to the VNET and virtual machines. This varies greatly from organization to organization.
<p>&nbsp;</p>

## Configuring Azure
To use a custom DNS server for a VNET on Azure, you must specify in the VNET settings the custom DNS server IP addresses:

- Navigate to the Settings `DNS server` tab and select "Custom". 
- Add the IP address of the DNS server and save.
<p>&nbsp;</p>

## Usage
This section contains details on configurations and settings that this module supports.

### Getting Started
See the example scenario in the tests directory which contains a ready-made terraform configuration for 1 private DNS server with 1 Forward Zone configured. Aside from the prereqs, all that is required to deploy is populating your own input variable values in the terraform.tfvars.example template that is provided in the given scenario subdirectory (and removing the .example file extension).

 