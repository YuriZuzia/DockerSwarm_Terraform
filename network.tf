resource "yandex_vpc_network" "def-net" {
  name = "def-net"
}
resource "yandex_vpc_subnet" "int-net1" {
  name = "int-net1"
  zone = var.zone
  v4_cidr_blocks = ["10.0.0.0/24"]
  network_id = "${yandex_vpc_network.def-net.id}"  
}
