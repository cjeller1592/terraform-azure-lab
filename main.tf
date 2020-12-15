# First declare the provider which is Azure...

provider "azurerm" {
  features {}
}

# Then we declare the resource group...for all the cool stuff to go in

resource "azurerm_resource_group" "group" {
  name                  = "lab1"
  location              = var.location
}

# After the resource group is the virtual network...the vm should exist within a private network

resource "azurerm_virtual_network" "network" {

  name                  = "labnetwork"
  address_space         = ["10.0.0.0/16"]
  location              = azurerm_resource_group.group.location
  resource_group_name   = azurerm_resource_group.group.name

}

# Then the Subnet!
# Subnets enable you to segment the virtual network into one or more sub-networks and allocate a portion of the virtual network's address space to each subnet.
# Also allows for security on that specific subnet with network security groups (nsg)

resource "azurerm_subnet" "subnet" {

  name                  = "coolkidsonly"
  resource_group_name   = azurerm_resource_group.group.name
  virtual_network_name  = azurerm_virtual_network.network.name
  address_prefixes      = ["10.0.2.0/27"]
}

# Adding a public IP to access the VM's via SSH

resource "azurerm_public_ip" "mycoolip" {

  name                   = "coolip"
  location               = azurerm_resource_group.group.location
  resource_group_name    = azurerm_resource_group.group.name
  allocation_method      = "Dynamic"
  idle_timeout_in_minutes = 15
}

# Now the network interface for Kali
# A network interface enables an Azure Virtual Machine to communicate with internet, Azure, and on-premises resources.
# For one machine at a time — think like how a network interface card is for one computer only!

resource "azurerm_network_interface" "kalinic" {

  name                    = "coolnic"
  location                = azurerm_resource_group.group.location
  resource_group_name     = azurerm_resource_group.group.name

  ip_configuration {

    name                  = "internal"
    subnet_id             = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id  = azurerm_public_ip.mycoolip.id

    }
}

# Now the network interface for the target machine

resource "azurerm_network_interface" "targetnic" {

  name                    = "targetnic"
  location                = azurerm_resource_group.group.location
  resource_group_name     = azurerm_resource_group.group.name

  ip_configuration {

    name                  = "internal"
    subnet_id             = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"

    }
}

# Create an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Now let's add a Kali VM & target machine

# Kali VM

resource "azurerm_linux_virtual_machine" "kali-box" {

  name                    = "kali"
  resource_group_name     = azurerm_resource_group.group.name
  location                = azurerm_resource_group.group.location
  size                    = "Standard_F2"
  admin_username          = "changemyname"
  network_interface_ids   = [
      azurerm_network_interface.kalinic.id,
      ]

  admin_ssh_key {
  username   = "changemyname"
  public_key = tls_private_key.example_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "kali-linux"
    offer     = "kali-linux"
    sku       = "kali"
    version   = "2019.2.0"
  }

  plan                    {
    name      = "kali"
    product   = "kali-linux"
    publisher = "kali-linux"
  }
}

# Target VM

resource "azurerm_linux_virtual_machine" "other-box" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  size                = "Standard_F2"
  admin_username      = var.target_user
  admin_password      = var.target_pw
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.targetnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# Output - Kali machine's IP & private key

output "kali_ip" {
    value     = azurerm_linux_virtual_machine.kali-box.public_ip_address
}

output "tls_private_key" { 
   value      = tls_private_key.example_ssh.private_key_pem 
   sensitive  = true
}
