resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "binddns"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.dns_server_private_ip
  }
}

#------------------------------------------------------------------------------
# Custom Data (cloud-init) arguments
#------------------------------------------------------------------------------
locals {
  custom_data_args = {
    # # Used for /etc/bind/named.conf.options file
    listen_on_cidrs = join(";\n    ", var.listen_on_cidrs)
    forwarders      = join(";\n    ", var.forwarders)
    # # Used for /etc/bind/named.conf.local file
    dns_zone = var.dns_zone
    # # Used for /etc/bind/dns.zone.com
    dns_hostname          = var.hostname
    soa_username          = var.soa_username
    dns_server_private_ip = var.dns_server_private_ip
    a_record_servername   = var.a_record_servername
    a_record_ip_address   = var.a_record_ip_address
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "binddnsosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.hostname
    admin_username = var.admin_username
    custom_data    = base64encode(templatefile("${path.module}/templates/dns_custom_data.sh.tpl", local.custom_data_args))
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = var.ssh_public_key
      path     = var.ssh_key_path
    }
  }
}