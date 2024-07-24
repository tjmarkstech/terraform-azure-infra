# Create a resource group
resource "azurerm_resource_group" "tj_rg" {
  name     = "tj-resources"
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "tj" {
  name                = "tj-network"
  resource_group_name = azurerm_resource_group.tj_rg.name
  location            = azurerm_resource_group.tj_rg.location
  address_space       =  var.vnet_ip
}

# Subnet 1
resource "azurerm_subnet" "tj1_subnet" {
  name                 = "tj-subnet"
  resource_group_name  = azurerm_resource_group.tj_rg.name
  virtual_network_name = azurerm_virtual_network.tj.name
  address_prefixes     = var.subnet1_ip
}

# Subnet 2
resource "azurerm_subnet" "tj2_subnet" {
  name                 = "subnet-2"
  resource_group_name  = azurerm_resource_group.tj_rg.name
  virtual_network_name = azurerm_virtual_network.tj.name
  address_prefixes     = var.subnet2_ip
}

resource "azurerm_public_ip" "tj_pub_ip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.tj_rg.name
  location            = azurerm_resource_group.tj_rg.location
  allocation_method   = "Static"

  tags = {
    environment = "tj_test"
  }
}

resource "azurerm_public_ip" "tj_pub_ip2" {
  name                = "acceptanceTestPublicIp2"
  resource_group_name = azurerm_resource_group.tj_rg.name
  location            = azurerm_resource_group.tj_rg.location
  allocation_method   = "Static"

  tags = {
    environment = "tj_test2"
  }
}

resource "azurerm_network_interface" "nic-1" {
  name                = "tj-nic-1"
  location            = azurerm_resource_group.tj_rg.location
  resource_group_name = azurerm_resource_group.tj_rg.name

  ip_configuration {
    name                          = "internal1"
    subnet_id                     = azurerm_subnet.tj1_subnet.id
    private_ip_address_allocation = "Dynamic" 
    public_ip_address_id          = azurerm_public_ip.tj_pub_ip.id
  }
}

resource "azurerm_network_interface" "nic-2" {
  name                = "tj-nic-2"
  location            = azurerm_resource_group.tj_rg.location
  resource_group_name = azurerm_resource_group.tj_rg.name

  ip_configuration {
    name                          = "internal2"
    subnet_id                     = azurerm_subnet.tj2_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tj_pub_ip2.id
  }
}

resource "azurerm_network_security_group" "tj_sg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.tj_rg.location
  resource_group_name = azurerm_resource_group.tj_rg.name

  security_rule {
    name                       = "tj_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "tj_test"
  }
}

resource "azurerm_network_security_group" "tj_sg_2" {
  name                = "acceptanceTestSecurityGroup2"
  location            = azurerm_resource_group.tj_rg.location
  resource_group_name = azurerm_resource_group.tj_rg.name

  security_rule {
    name                       = "tj_sg_2"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "tj_test_2"
  }
}

resource "azurerm_network_interface_security_group_association" "nic-sg-1" {
  network_interface_id      = azurerm_network_interface.nic-1.id
  network_security_group_id = azurerm_network_security_group.tj_sg.id
}

resource "azurerm_network_interface_security_group_association" "nic-sg-2" {
  network_interface_id      = azurerm_network_interface.nic-2.id
  network_security_group_id = azurerm_network_security_group.tj_sg_2.id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.tj_rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "tj_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.tj_rg.location
  resource_group_name      = azurerm_resource_group.tj_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "tj_vm" {
  name                = "tj-vm"
  resource_group_name = azurerm_resource_group.tj_rg.name
  location            = azurerm_resource_group.tj_rg.location
  size                = var.vm_size
  network_interface_ids = [
    azurerm_network_interface.nic-1.id,
  ]

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = var.adminusername
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.tj_storage_account.primary_blob_endpoint
  }
}
