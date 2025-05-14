terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.90"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  token     = var.token
}

resource "yandex_vpc_network" "kittygram_network" {
  name = "kittygram-network"
}

resource "yandex_vpc_subnet" "kittygram_subnet" {
  name           = "kittygram-subnet"
  network_id     = yandex_vpc_network.kittygram_network.id
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_vpc_security_group" "kittygram_sg" {
  name        = "kittygram-sg"
  network_id  = yandex_vpc_network.kittygram_network.id

  ingress {
    protocol = "TCP"
    ports    = [22, 9000]
  }

  egress {
    protocol = "all"
    ports    = [0-65535]
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
      image_id = "fd8m0t5d0nhqetmd0plh"
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

resource "yandex_storage_bucket" "tf_state" {
  bucket = "kittygram-terraform-state"
  acl    = "private"
}
