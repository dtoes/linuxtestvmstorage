resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
      tags = {
        environment = "${var.omgeving}"
    }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
        tags = {
        environment = "${var.omgeving}"
    }
}

resource "azurerm_subnet" "intern" {
  name                 = "intern"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "mypubliclinuxip" {
    name                         = "${var.prefix}-lxpip"
    location                     = azurerm_resource_group.main.location
    resource_group_name          = azurerm_resource_group.main.name
    allocation_method            = "Static"

    tags = {
        environment = "${var.omgeving}"
    }
}

resource "azurerm_network_interface" "linux" {
  name                = "${var.prefix}-lxnic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.intern.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypubliclinuxip.id
  }
            tags = {
        environment = "${var.omgeving}"
    }
}

resource "azurerm_network_security_group" "webserver" {
  name                = "http_webserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = azurerm_subnet.intern.address_prefix
  }
    security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_subnet.intern.address_prefix
  }
        tags = {
        environment = "${var.omgeving}"
    }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "${var.prefix}-lx"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.linux.id]
  vm_size               = "Standard_F4"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Linux machine"
    admin_username = var.gebruikersnaam
    admin_password = var.wachtwoord
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    environment = "${var.omgeving}"
    }
}

resource "azurerm_app_service_plan" "main" {
  name                = "${var.prefix}-asp"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "main" {
  name                = "${var.prefix}-appservice"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  app_service_plan_id = "${azurerm_app_service_plan.main.id}"

  site_config {
    app_command_line = ""
    linux_fx_version = "DOCKER|appsvcsample/python-helloworld:latest"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
  }
}





/*
resource "azurerm_managed_disk" "example" {
  name                 = "${var.prefix}-disk1"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = azurerm_virtual_machine.example.id
  lun                = "10"
  caching            = "ReadWrite"
}
*/
