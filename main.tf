terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "mtc-rg" {
  name     = "mtc-resources"
  location = "West Europe"
  tags = {
    environment = "development"
  }
}

resource "azurerm_virtual_network" "mtc-vn" {
  name                = "mtc-network"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "development"
  }

}

resource "azurerm_subnet" "mtc-subnet" {
  name                 = "mtc-subnet-1"
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  virtual_network_name = azurerm_virtual_network.mtc-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "mtc-nsg" {
  name                = "mtc-nsg-1"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  tags = {
    environment = "development"
  }
}

resource "azurerm_network_security_rule" "mtc-nsr" {
  name                        = "allowDevInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  network_security_group_name = azurerm_network_security_group.mtc-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "mtc-nsga" {
  subnet_id                 = azurerm_subnet.mtc-subnet.id
  network_security_group_id = azurerm_network_security_group.mtc-nsg.id
}

resource "azurerm_public_ip" "mtc-ip" {
  name                = "mtc-public-ip"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "development"
  }
}

resource "azurerm_network_interface" "mtc-ni" {
  name                = "mtc-network-interface"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mtc-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc-ip.id
  }

  tags = {
    environment = "development"
  }
}

resource "azurerm_linux_virtual_machine" "mtc-vm" {
  name                = "mtc-virtual-machine"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  size                = "Standard_B1s"
  admin_username      = "lololo"
  network_interface_ids = [
    azurerm_network_interface.mtc-ni.id,
  ]

  custom_data = filebase64("custom-data.tpl")


  admin_ssh_key {
    username   = "lololo"
    public_key = file("~/.ssh/azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

data "azurerm_public_ip" "mtc-ip-data" {
  name                = azurerm_public_ip.mtc-ip.name
  resource_group_name = azurerm_resource_group.mtc-rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc-vm.name}: ${data.azurerm_public_ip.mtc-ip-data.ip_address}"
}

output "show_os_variable" {
  value = var.host_os == "linux" ? "Linux" : "Not Linux"
}