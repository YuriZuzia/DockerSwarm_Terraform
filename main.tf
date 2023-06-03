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
  description = "Docker Swarm cluster manager"
  name = "srv1"
  hostname = "srv1"
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
    ssh-keys = "yuri:${file(var.ssh-path)}" //ssh-path described in separate secrets.tf file
    user-data = <<EOF
#!/bin/bash
docker run -d --name=dev-consul -p 8500:8500 -e CONSUL_BIND_INTERFACE=eth0 consul
docker swarm init --advertise-addr $(ip -br a show eth0 | awk '{print$3}'|cut -d'/' -f1)
worker_key=$(docker swarm join-token -q worker)
curl --request PUT --data $worker_key http://localhost:8500/v1/kv/worker_key
EOF
  }
}
locals {
  external_ip = ["${yandex_compute_instance.srv1.network_interface.0.nat_ip_address}"]
}
output "locals" {
  value = local.external_ip
}


resource "yandex_compute_instance" "worker" {
  description = "Docker Swarm cluster members"
  count = 2
  hostname = "wrk${count.index + 1}"
  name = "wrk${count.index + 1}"
  platform_id = "standard-v1"
  zone = "${var.zone}"
  resources {
    core_fraction = 20
    cores = 2
    memory = 2
  }
  scheduling_policy {
    preemptible = true
  }
  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.container-optimized-image.id}"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.int-net1.id}"
    nat = true
  }
  metadata = {
    ssh-keys = "yuri:${file(var.ssh-path)}"
    user-data = <<EOF
#!/bin/bash
worker_key=$(curl -s http://srv1:8500/v1/kv/worker_key?raw)
docker swarm join --token $worker_key srv1:2377
EOF
  }
  depends_on = [ yandex_compute_instance.srv1 ]
}
