terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket       = "crocksgift-kittygram-terraform-state"
    key          = "terraform/state.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = "/home/runner/.yc/key.json"
}

resource "yandex_vpc_network" "kittygram_network" {
  name = "kittygram-network"
}

resource "yandex_vpc_gateway" "internet_gateway" {
  name = "internet-gateway"
}

resource "yandex_vpc_route_table" "internet_route_table" {
  network_id = yandex_vpc_network.kittygram_network.id
  name       = "internet-route-table"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_gateway_id = yandex_vpc_gateway.internet_gateway.default_gateway_id
  }
}

resource "yandex_vpc_subnet" "kittygram_subnet" {
  name           = "kittygram-subnet"
  network_id     = yandex_vpc_network.kittygram_network.id
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.0.0/24"]
  route_table_id = yandex_vpc_route_table.internet_route_table.id
}

resource "yandex_vpc_security_group" "kittygram_sg" {
  name       = "kittygram-sg"
  network_id = yandex_vpc_network.kittygram_network.id

  ingress {
    protocol        = "TCP"
    port            = 22
    description     = "SSH Access"
    v4_cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    protocol        = "TCP"
    port            = 9000
    description     = "Kittygram App Access"
    v4_cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 0
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_compute_instance" "kittygram_vm" {
  name        = "kittygram-vm"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      type     = "network-hdd"
      image_id = "fd88o3huv4mm2jndnrl1"
      size     = 20
    }
  }
  network_interface {
    subnet_id   = yandex_vpc_subnet.kittygram_subnet.id
    nat         = true
    security_group_ids = [yandex_vpc_security_group.kittygram_sg.id]
  }
  metadata = {
    user-data = file("cloud-init.yaml")
    ssh-keys  = "${var.vm_user}:${var.ssh_public_key}"
  }
}
