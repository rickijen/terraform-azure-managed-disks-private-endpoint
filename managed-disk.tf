#########################
## Managed Disk - Main ##
#########################

locals {
  os_disk_name = "os-disk"
  disk_name = "contoso-disk1"
}

# Create Private DNS Zone
resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.network-rg.name
}

# Create Private DNS Zone Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  name                  = "vnet_link"
  resource_group_name = azurerm_resource_group.network-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.network-vnet.id
}

# Create Disk Access
resource "azurerm_disk_access" "disk_access" {
  name                = "disk-access"
  location             = azurerm_resource_group.network-rg.location
  resource_group_name  = azurerm_resource_group.network-rg.name
}

# Create Azure Managed OS Disk
resource "azurerm_managed_disk" "disk_os" {
  name                 = local.os_disk_name
  location             = azurerm_resource_group.network-rg.location
  resource_group_name  = azurerm_resource_group.network-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Copy"
  source_resource_id   = "/subscriptions/2b46462f-5b41-421e-9b6f-34fcd0522e1c/resourceGroups/linux/providers/Microsoft.Compute/snapshots/ubuntu-snapshot"
  network_access_policy = "AllowPrivate" // AllowAll, AllowPrivate, and DenyAll.
  disk_access_id = azurerm_disk_access.disk_access.id

  tags = {
    environment = var.environment
  }
}

# Create Azure Managed Disk
resource "azurerm_managed_disk" "disk1" {
  name                 = local.disk_name
  location             = azurerm_resource_group.network-rg.location
  resource_group_name  = azurerm_resource_group.network-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  network_access_policy = "AllowPrivate" // AllowAll, AllowPrivate, and DenyAll.
  disk_access_id = azurerm_disk_access.disk_access.id

  tags = {
    environment = var.environment
  }
}

# Attach Azure Managed Disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk1" {
  managed_disk_id    = azurerm_managed_disk.disk1.id
  virtual_machine_id = azurerm_virtual_machine.linux-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

# Create Private Endpint
resource "azurerm_private_endpoint" "endpoint" {
  name                = "disks-pe"
  resource_group_name = azurerm_resource_group.network-rg.name
  location            = azurerm_resource_group.network-rg.location
  subnet_id           = azurerm_subnet.endpoint-subnet.id

  private_service_connection {
    name                           = "disks-psc"
    private_connection_resource_id = azurerm_disk_access.disk_access.id
    is_manual_connection           = false
    subresource_names              = ["disks"]
  }
}

# Create DNS A Record
resource "azurerm_private_dns_a_record" "dns_a" {
  name                = "disks-dns"
  zone_name           = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.network-rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}
