# terraform-azurerm-bind-dns-server

## Background
This module deploys an ubuntu VM into the specified Azure VNET and subnet, installs Bind9, and configures the bind9 server to create a DNS forwarder and lookup zone based on the inputs provided.
<p>&nbsp;</p>

When you are using Azure-provided name resolution, Azure Dynamic Host Configuration Protocol (DHCP) provides an internal DNS suffix (.internal.cloudapp.net) to each VM. This suffix enables host name resolution because the host name records are in the internal.cloudapp.net zone. When you are using your own name resolution solution, this suffix is not supplied to VMs because it interferes with other DNS architectures (like domain-joined scenarios). Instead, Azure provides a non-functioning placeholder (reddog.microsoft.com) which can be viewed in the `/etc/resolv.conf` file.

>Note: See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances
<p>&nbsp;</p>

## Prerequisites
- Routing may need to be configured based on the location of the DNS server relative to the VNET and virtual machines. This varies greatly from organization to organization.
- The DNS server must have the ability to download required packages from the internet. 
<p>&nbsp;</p>

## Usage
This section contains details on configurations and settings that this module supports.

### Getting Started
See the example scenario in the tests directory which contains a ready-made terraform configuration for 1 private DNS server with 1 Forward Zone configured. Aside from the prereqs, all that is required to deploy is populating your own input variable values in the terraform.tfvars.example template that is provided in the given scenario subdirectory (and removing the .example file extension).
<p>&nbsp;</p>

### Deploying the Server
The section of code below is an example taken from the `tests/single-server/terraform.tfvars.example` file. You are required to define an existing Resource Group and Subnet ID for the VM to be put into. This module only supports prviate IP addressing at this time and one is required. Choose a hostname, admin username, and ssh public key to upload to the VM as well.

```hcl
# --- DNS Server --- #
resource_group_name   = "prereqs-rg"    
subnet_id             = "/subscriptions/12345678-1111-aaaa-2222-abcdefg123/resourceGroups/prereqs-rg/providers/Microsoft.Network/virtualNetworks/dns-vnet/subnets/dns-subnet"
dns_server_private_ip = "10.0.2.60"
hostname = "binddns"
admin_username        = "binddnsadmin"
ssh_public_key        = "ssh-rsa AAAAB3Nzxxx= example@example"
ssh_key_path = "/home/binddnsadmin/.ssh/authorized_keys"
```
### Configuring the DNS Server
Terraform will use the `dns_custome_data.sh.tpl` or `dns_fwd_zone_custom_data.sh.tpl` script ( depending on if you set `forward_zone_enabled = true` or not ) from the `templates` directory to interpolate these values into a script that will install and configure the bind9 dns service on the VM.
>Note: At this time the module only supports providing 1 zone.


```hcl
# --- DNS Configuration --- #
listen_on_cidrs     = ["10.0.2.0/24", "172.22.1.0/24"]          
forwarders          = ["8.8.8.8", "8.8.4.4", "168.63.129.16"]   
dns_zone            = "mydomain.com"                            
soa_username        = "root"                                    
a_record_servername = "app.mydomain.com"                       
a_record_ip_address = "10.0.2.4"
forward_zone        = "forwardzone-domain.com
forward_zone_ip     = "168.63.129.16"
forward_zone_enabled = true                            
```

### Configuring Azure
To use a custom DNS server for a VNET on Azure, you must specify in the VNET settings the custom DNS server IP addresses:

- Navigate to the Settings `DNS server` tab and select "Custom". 
- Add the IP address of the DNS server and save.
>Note: If you change the VNET DNS server to a custom one and then try to deploy the DNS server into that VNET, it will fail because it cannot resolve addresses required to download bind9. 
- If you are using an Azure private DNS zone, you must create a forward zone on the DNS server with the name of the private zone that forwards requests to the Azure DNS IP `168.63.129.16`. See below for an example:
```hcl
zone "postgres.database.azure.com" {
type forward;
forward only;
forwarders { 168.63.129.16; };
};
```
<p>&nbsp;</p>

## Verifying the Deployment
- A client deployed into the VNET that you have configured with the custom DNS server should be able to `dig @<dns_server_private_ip> <fqdn_of_a_record_host>`
- Alternatively, depending on how you setup your records, a simple `nslookup` of an A record within your DNS server should resolve.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_a_record_ip_address"></a> [a\_record\_ip\_address](#input\_a\_record\_ip\_address) | The IP address for the server you are creating an A record for. | `string` | n/a | yes |
| <a name="input_a_record_servername"></a> [a\_record\_servername](#input\_a\_record\_servername) | The FQDN of a host you wish to create an A record for. | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username used for SSH. | `string` | `"binddnsadmin"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for taggable Azure resources. | `map(string)` | `{}` | no |
| <a name="input_dns_server_private_ip"></a> [dns\_server\_private\_ip](#input\_dns\_server\_private\_ip) | A private IP address to assign to the DNS VM. | `string` | n/a | yes |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | The domain name of a DNS zone you wish to create records within. Example: domain.com | `string` | n/a | yes |
| <a name="input_forwarders"></a> [forwarders](#input\_forwarders) | A list of DNS servers to forward requests to. | `list(string)` | <pre>[<br>  "8.8.8.8",<br>  "8.8.4.4",<br>  "168.63.129.16"<br>]</pre> | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname of the VM. | `string` | `"binddns"` | no |
| <a name="input_listen_on_cidrs"></a> [listen\_on\_cidrs](#input\_listen\_on\_cidrs) | A list of CIDR addresses that the DNS server will listen on for requests. Requests from CIDR ranges not listed will be ignored. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region to deploy into. | `string` | `"east us"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Friendly name prefix for unique Azure resource naming. | `string` | `"binddns"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of an existing resource group to deploy into. | `string` | n/a | yes |
| <a name="input_soa_username"></a> [soa\_username](#input\_soa\_username) | The first half of the email address for the owner of this domain. An example of this would be root if the owner was root@example.com. | `string` | n/a | yes |
| <a name="input_ssh_key_path"></a> [ssh\_key\_path](#input\_ssh\_key\_path) | The path on the VM to place the SSH public key. | `string` | `"/home/binddnsadmin/.ssh/authorized_keys"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The public key to be placed onto the VM. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet to deploy the VM into. | `string` | n/a | yes |

## Outputs

No outputs.

 