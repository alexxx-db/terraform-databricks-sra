resource "azurerm_subnet" "plsubnet" {
  name                                      = "${local.prefix}-privatelink"
  resource_group_name                       = azurerm_resource_group.this.name
  virtual_network_name                      = azurerm_virtual_network.this.name
  address_prefixes                          = [cidrsubnet(local.cidr, 3, 2)]
  private_endpoint_network_policies_enabled = true // set to true to disable subnet policy
}

//dbfs pvt endpoint - dfs
resource "azurerm_private_endpoint" "dbfspe_dfs" {
  name                = "dbfspvtendpoint-dfs"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet


  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-dbfs-dfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_dfs.id]
  }
}
resource "azurerm_private_dns_zone" "dnsdbfs_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink_dfs" {
  name                  = "dbfsspokevnetconnection-dfs"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs_dfs.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
}

//dbfs pvt endpoint - blob
resource "azurerm_private_endpoint" "dbfspe_blob" {
  name                = "dbfspvtendpoint-blob"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet


  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-dbfs-blob"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_blob.id]
  }
}
resource "azurerm_private_dns_zone" "dnsdbfs_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink_blob" {
  name                  = "dbfsspokevnetconnection-blob"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs_blob.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
}