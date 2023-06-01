terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
provider "yandex" {
  //OAth-token described in separate secrets.tf file
  token = "${var.OAuth-token}"
  cloud_id = "${var.cloud_id}"
  folder_id = "${var.folder_id}"
  zone = "${var.zone}"
}
resource "yandex_compute_instance" "srv1" {
  description = "D1.7 home work"
  name = "srv1"
  platform_id = "standard-v1"
  zone = "${var.zone}"

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  scheduling_policy {
  preemptible = true
}
  boot_disk {
    initialize_params {
      //image_id = "${var.os-image-id}"
      image_id = "${data.yandex_compute_image.container-optimized-image.id}"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.int-net1.id}"
    nat = true
  }
  metadata = {
    serial-port-enable = 0
    ssh-keys = "yuri:${file(var.ssh-path)}"
  }
}
locals {
  external_ip = ["${yandex_compute_instance.srv1.network_interface.0.nat_ip_address}"]
}
